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
        padding: EdgeInsets.only(top: 50.0, left: 40.0),
        decoration: BoxDecoration(
          color: Colors.white70,
          image: DecorationImage(
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.25), BlendMode.dstATop),
              image: NetworkImage(
                  'https://res.starwarsccg.org/cards/Dagobah-Light/large/quickdraw.gif')),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '•Quick Draw',
              // https://res.starwarsccg.org/cards/Dagobah-Light/large/quickdraw.gif
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 36.0,
              ),
            ),
            Text(
              'Fast SWCCG Deckbuilder',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                fontSize: 18.0,
              ),
            ),
          ],
        ),
      ),
      _drawerItem(context, 'Side', Icons.keyboard_arrow_left),
      _drawerItem(context, 'Objective', Icons.filter_1),
      _drawerItem(context, 'Pulled by Objective',
          Icons.subdirectory_arrow_right_rounded),
      _drawerItem(context, 'Starting Interrupt', Icons.filter_2),
      _drawerItem(context, 'Pulled By Starting Interrupt',
          Icons.subdirectory_arrow_right_rounded),
      _drawerItem(context, 'Main Deck', Icons.filter_3),
      _drawerItem(context, 'Starting Effect', Icons.filter_4),
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
