import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Widget getDrawer(BuildContext context) {
  return Drawer(
    // Add a ListView to the drawer. This ensures the user can scroll
    // through the options in the drawer if there isn't enough vertical
    // space to fit everything.
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(color: Colors.blue),
          child: Text('Drawer Example'),
        ),
        ListTile(
          title: const Text('Page 1'),
          onTap: () {
            // Update the state of the app.
            context.go("/");
          },
        ),
        ListTile(
          title: const Text('Page 2'),
          onTap: () {
            // Update the state of the app.
            context.go('/second');
          },
        ),
      ],
    ),
  );
}
