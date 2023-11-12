import 'package:digikam/dialog/statistic_month_dialog.dart';
import 'package:flutter/material.dart';
import 'dialog/settings_dialog.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            child: Text('Verwaltung'),
          ),
          ListTile(
            title: const Text('Statistik nach Monat'),
            onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => StatisticMonthDialog()))
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: ()
            async {
              await showDialog(
                  context: context,
                  builder: (context) => const SettingsMask());
            },
          ),
          ListTile(
            title: const Text('Refresh Cache'),
            onTap: () {
              // refresh Caches
              Navigator.pop(context);
            },
          )
        ],
      ),
//          child: ,
    );
  }

}
