import 'package:flutter/widgets.dart';
import 'package:notes/utilities/Dialog/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: "Logout",
    content: 'Are you sure you wan to log out?',
    optionsBuilder: () => {
      'Cancel':false,
      'Log out':true
    },
  ).then(
        (value) => value ?? false,
  );
}