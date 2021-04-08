import 'package:flutter/material.dart';

class QuickDrawer extends StatelessWidget {
  const QuickDrawer({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: _drawerWidgets(context),
      ),
    );
  }

  List<Widget> _drawerWidgets(context) {
    return [
      DrawerHeader(
        decoration: BoxDecoration(
          color: Colors.blueGrey,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '•Quick Draw',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
              ),
            ),
            Text(
              'Fast SWCCG Deckbuilder',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      _drawerItem(context, 'Side', Icons.filter_1),
      _drawerItem(context, 'Objective', Icons.filter_2),
      _drawerItem(context, 'Pulled by Objective',
          Icons.subdirectory_arrow_right_rounded),
      _drawerItem(context, 'Starting Interrupt', Icons.filter_3),
      _drawerItem(context, 'Pulled By Starting Interrupt',
          Icons.subdirectory_arrow_right_rounded),
      _drawerItem(context, 'Main Deck', Icons.filter_4),
      _drawerItem(context, 'Starting Effect', Icons.filter_5),
      _drawerItem(
          context, 'Defensive Shields', Icons.subdirectory_arrow_right_rounded),
    ];
  }

  Widget _drawerItem(context, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // close the drawer
      },
    );
  }
}
