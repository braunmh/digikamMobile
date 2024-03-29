import 'package:digikam/dialog/statistic_keyword_dialog.dart';
import 'package:digikam/dialog/statistic_month_dialog.dart';
import 'package:digikam/services/backend_service.dart';
import 'package:flutter/material.dart';
import 'dialog/settings_dialog.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({
    super.key,
  });

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
              .push(MaterialPageRoute(builder: (context) => const StatisticMonthDialog()))
          ),
          ListTile(
            title: const Text('Statistik nach Stichwort'),
            onTap: () async {
              await showDialog(
                context: context,
                builder: (context) => const StatisticKeywordDialog());
            }
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
            title: const Text('Refresh local Caches'),
            onTap: () {
              CacheService.refreshClient();
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Refresh Server Caches'),
            onTap: () {
              CacheService.refreshServer();
              Navigator.pop(context);
            },
          )
        ],
      ),
//          child: ,
    );
  }

}
