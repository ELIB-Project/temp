import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

final List<String> genderItems = [
  'Male',
  'Female',
];

String? selectedValue;

final _formKey = GlobalKey<FormState>();

class MyWidgetPage extends StatelessWidget {
  const MyWidgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
            child: Row(
          children: [
            Container(
              color: Colors.red,
              height: 100,
              child: Text("1asdfasdfasdfasdfasdfasdf"),
            ),
            Expanded(
                child: Container(
              color: Colors.blue,
              height: 100,
              child: Column(
                children: [
                  Expanded(child: Text("남는공간이 어디")),
                  Expanded(child: Text("1asdasdasdasdasd")),
                ],
              ),
            )),
            Expanded(
              child: Container(
                color: Colors.green,
                height: 100,
                child: Text("1"),
              ),
            ),
          ],
        )),
      ),
    );
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SelecteBirth(),
  );
}

Form SelecteBirth() {
  return Form(
    key: _formKey,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              hintText: 'Enter Your Full Name.',
              hintStyle: const TextStyle(fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          const SizedBox(height: 30),
          DropdownButtonFormField2(
            decoration: InputDecoration(
              //Add isDense true and zero Padding.
              //Add Horizontal padding using buttonPadding and Vertical padding by increasing buttonHeight instead of add Padding here so that The whole TextField Button become clickable, and also the dropdown menu open under The whole TextField Button.
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              //Add more decoration as you want here
              //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
            ),
            isExpanded: true,
            hint: const Text(
              'Select Your Gender',
              style: TextStyle(fontSize: 14),
            ),
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.black45,
            ),
            iconSize: 30,
            buttonHeight: 60,
            buttonPadding: const EdgeInsets.only(left: 20, right: 10),
            dropdownDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            items: genderItems
                .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ))
                .toList(),
            validator: (value) {
              if (value == null) {
                return 'Please select gender.';
              }
            },
            onChanged: (value) {
              //Do something when changing the item if you want.
            },
            onSaved: (value) {
              selectedValue = value.toString();
            },
          ),
          const SizedBox(height: 30),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
              }
            },
            child: const Text('Submit Button'),
          ),
        ],
      ),
    ),
  );
}
