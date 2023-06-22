import 'package:flutter/material.dart';
import 'package:mk_tv_app/routes.dart';

class MkDrawer extends StatelessWidget {
  const MkDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
              decoration: BoxDecoration(
                  // color: Colors.white,
                  // color: Colors.lightBlue,
                  ),
              child: Image(
                image: AssetImage("lib/myassets/mklogo.png"),
                // color: Color.fromARGB(255, 229, 137, 10),
                width: 256,
              )),
          ListTile(
            onTap: () {
              Navigator.pushNamed(context, RouteGenerator.settingsPage);
            },
            leading: const Icon(Icons.settings_outlined),
            title: const Text(
              'Settings',
              style: TextStyle(fontSize: 16),
            ),
          ),
          const AboutListTile(
            icon: Icon(Icons.info_outline),
            applicationName: "MkTube",
            applicationVersion: "1.0",
            applicationIcon: ImageIcon(
              AssetImage("lib/myassets/mklogo.png"),
              color: Colors.lightBlue, // Color.fromARGB(255, 229, 137, 10),
              size: 64,
            ),
            applicationLegalese: "\u{a9} 2015 E.C Mahibere Kidusan",
            aboutBoxChildren: [
              Text("ያየነውን እንናገራለን የሰማነውንም እንመሰክራለን።"),
              Text("https://eotcmk.org/a/")
            ],
          )
        ],
      ),
    );
  }
}
