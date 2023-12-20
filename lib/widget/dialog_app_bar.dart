import 'package:flutter/material.dart';

/// Implements a custom AppBar, which can be used in Dialogs
///
class DialogAppBar extends StatelessWidget implements PreferredSizeWidget {

  final Size size = const Size.fromHeight(kToolbarHeight);
  final String title;

  const DialogAppBar({
    super.key,
    required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: BackButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Size get preferredSize => size;
}
