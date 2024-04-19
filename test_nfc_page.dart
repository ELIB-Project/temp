import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class _AndroidSessionDialog extends StatefulWidget {
  const _AndroidSessionDialog(this.alertMessage, this.handleTag);

  final String alertMessage;

  final String Function(NfcTag tag) handleTag;

  @override
  State<StatefulWidget> createState() => _AndroidSessionDialogState();
}

class _AndroidSessionDialogState extends State<_AndroidSessionDialog> {
  String? _alertMessage;
  String? _errorMessage;

  String? _result;

  @override
  void initState() {
    super.initState();

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          _result = widget.handleTag(tag);

          var ndef = Ndef.from(tag);
          if (ndef == null || !ndef.isWritable) {
            throw "쓰기가 불가능한 NFC 태그 입니다.";
          }
          // 여기 위주로 확인해보자!!
          NdefMessage message = NdefMessage(<NdefRecord>[
            NdefRecord.createUri(Uri.parse('https://eins.page.link/home')),
          ]);

          await ndef.write(message);
          await NfcManager.instance.stopSession();

          setState(() => _alertMessage = "NFC 태그를 인식하였습니다.");
        } catch (e) {
          await NfcManager.instance.stopSession();

          setState(() => _errorMessage = '$e');
        }
      },
    ).catchError((e) => setState(() => _errorMessage = '$e'));
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _errorMessage?.isNotEmpty == true
            ? "오류"
            : _alertMessage?.isNotEmpty == true
                ? "성공"
                : "준비",
      ),
      content: Text(
        _errorMessage?.isNotEmpty == true
            ? _errorMessage!
            : _alertMessage?.isNotEmpty == true
                ? _alertMessage!
                : widget.alertMessage,
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
              _errorMessage?.isNotEmpty == true
                  ? "확인"
                  : _alertMessage?.isNotEmpty == true
                      ? "완료"
                      : "취소",
              style: TextStyle(color: Colors.amber)),
          onPressed: () => Navigator.of(context).pop(_result),
        ),
      ],
    );
  }
}

String _handleTag(NfcTag tag) {
  try {
    final List<int> tempIntList;

    if (Platform.isIOS) {
      tempIntList = List<int>.from(tag.data["mifare"]["identifier"]);
    } else {
      tempIntList =
          List<int>.from(Ndef.from(tag)?.additionalData["identifier"]);
    }
    String id = "";

    tempIntList.forEach((element) {
      id = id + element.toRadixString(16);
    });

    return id;
  } catch (e) {
    throw "NFC 데이터를 가져올 수 없습니다.";
  }
}
