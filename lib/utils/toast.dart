import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum ToastType { success, error, info, warning }

class Toasts {
  static void show(
    BuildContext context,
    String message, {
    required ToastType type,
    SnackBarAction? action,
  }) {
    FToast fToast = FToast();
    fToast.init(context);

    final Color backgroundColor = _getBackgroundColor(type, context);
    final Color textColor = _getTextColor(type, context);
    final Icon icon = _getIcon(type);

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: backgroundColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // change to max to fill width
        children: [
          icon,
          const SizedBox(width: 12.0),
          Expanded(child: Text(message, style: TextStyle(color: textColor))),
        ],
      ),
    );

    fToast.removeQueuedCustomToasts();
    fToast.showToast(
      child: toast,
      isDismissible: true,
      fadeDuration: Duration(milliseconds: 500),
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }

  static Color _getBackgroundColor(ToastType type, BuildContext context) {
    final theme = Theme.of(context);
    switch (type) {
      case ToastType.success:
        return Colors.green.shade600;
      case ToastType.error:
        return Colors.red.shade600;
      case ToastType.warning:
        return Colors.orange.shade600;
      case ToastType.info:
        return theme.colorScheme.primary;
    }
  }

  static Color _getTextColor(ToastType type, BuildContext context) {
    return Colors.white;
  }

  static Icon _getIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icon(Icons.check_circle, color: Colors.white);
      case ToastType.error:
        return Icon(Icons.error, color: Colors.white);
      case ToastType.warning:
        return Icon(Icons.warning, color: Colors.white);
      case ToastType.info:
        return Icon(Icons.info, color: Colors.white);
    }
  }
}
