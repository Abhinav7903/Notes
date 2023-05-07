import 'package:flutter/widgets.dart';
import 'package:notes/utilities/Dialog/generic_dialog.dart';

Future<void> showErrorDialog(
    BuildContext context,
    String text,
    ) {
  return showGenericDialog<void>(
    context: context,
    title: 'An error occurred',
    content: text,
    optionsBuilder: () => {
      'ok': null,
    },
  );
}