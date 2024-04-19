import 'package:flutter/material.dart';

// class VerticalTabBarExample extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Vertical Tab Bar Example'),
//         ),
//         body: VerticalTabBarLayout(),
//       ),
//     );
//   }
// }

// class VerticalTabBarLayout extends StatefulWidget {
//   @override
//   _VerticalTabBarLayoutState createState() => _VerticalTabBarLayoutState();
// }

// class _VerticalTabBarLayoutState extends State<VerticalTabBarLayout>
//     with TickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           // Adjust the width to control the space taken by the tab bar
//           width: 100,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Tab(text: 'Tab 1'),
//               Tab(text: 'Tab 2'),
//               Tab(text: 'Tab 3'),
//             ],
//           ),
//         ),
//         Expanded(
//           child: TabBarView(
//             controller: _tabController,
//             children: [
//               Center(child: Text('Tab 1 Content')),
//               Center(child: Text('Tab 2 Content')),
//               Center(child: Text('Tab 3 Content')),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

class VerticalTabBarExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Vertical Tab Bar Example'),
        ),
        body: VerticalTabBarLayout(),
      ),
    );
  }
}

class VerticalTabBarLayout extends StatefulWidget {
  @override
  _VerticalTabBarLayoutState createState() => _VerticalTabBarLayoutState();
}

class _VerticalTabBarLayoutState extends State<VerticalTabBarLayout>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<String> tabNames = ['Tab 1', 'Tab 2', 'Tab 3'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabNames.length, vsync: this);
  }

  void addTab() {
    setState(() {
      int newTabIndex = tabNames.length + 1;
      tabNames.add('Tab $newTabIndex');
      _tabController = TabController(length: tabNames.length, vsync: this);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int index = 0; index < tabNames.length; index++)
                ListTile(
                  title: Text(tabNames[index]),
                  onTap: () {
                    _tabController.animateTo(index);
                  },
                ),
              ElevatedButton(
                onPressed: addTab,
                child: Text('Add Tab'),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              for (String tabName in tabNames)
                Center(child: Text('$tabName Content')),
            ],
          ),
        ),
      ],
    );
  }
}
