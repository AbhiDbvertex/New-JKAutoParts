import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class AjugnuFlushbar {
  static void createFlushBar(BuildContext context, String errorMessage,
      {Icon icon = const Icon(Icons.error_outline, color: Colors.black), int duration = 2500,
        String title = 'Error',  FlushbarPosition position = FlushbarPosition.TOP}) {
    if (errorMessage.isEmpty ) {
      errorMessage = 'Sorry to disturb, there was an empty message for you';
    }
    Flushbar(
      flushbarStyle: FlushbarStyle.FLOATING,
      message: errorMessage,
      flushbarPosition: position,
      duration: Duration(milliseconds: duration),
      backgroundColor: title=='Error'?Colors.red:Theme.of(context).colorScheme.inversePrimary,
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      margin: const EdgeInsets.all(18),
      icon: icon,
      title: title,
      titleColor: title=='Error'?Colors.white:Theme.of(context).colorScheme.onSurface,
      messageColor:title=='Error'?Colors.white:Theme.of(context).colorScheme.onSurface,
    ).show(context);
  }

  static void showError(BuildContext context, String errorMessage) {
    createFlushBar(context, errorMessage);
  }

  static void showWarning(BuildContext context, String warningMessage) {
    createFlushBar(context, warningMessage, icon: const Icon(Icons.warning, color: Colors.yellow),
        title: 'Warning');
  }

  static void showInstruction(BuildContext context, String instructionMessage) {
    createFlushBar(context, instructionMessage, icon: const Icon(Icons.notifications, color: Colors.yellow), title: 'Instruction');
  }

  static void showSuccess(BuildContext context, String successMessage) {
    createFlushBar(context, successMessage, icon: const Icon(Icons.done, color: Colors.green), title: 'Success');
  }
  static Future<void> showDialogs(BuildContext context, {required String title,required String message,}){
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap "OK" to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title:  Text(title,style: TextStyle(fontSize: 20,color: Colors.white),),
          content: Text(message,style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.red.shade400,
          actions: <Widget>[
            TextButton(
              child: const Text('OK',style: TextStyle(fontSize: 20,color: Colors.white),),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }
}