import 'package:flutter/material.dart';
import '../res/constants.dart';

class MyAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? cancelText;
  final String? confirmText;
  final void Function()? myOnPressed;
  final bool infoDialog;
  final bool onlyAction;
  final Color? confirmColor;

  final Widget? widgetContent;

  const MyAlertDialog({
    Key? key,
    required this.title,
    required this.message,
    this.cancelText,
    this.confirmText,
    this.myOnPressed,
    this.infoDialog = true,
    this.onlyAction = false,
    this.widgetContent,
    this.confirmColor,
  }) : super(key: key);

  final TextStyle _titleText = const TextStyle(fontSize: 22, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    String finalCancelText = cancelText ?? 'Ok';
    String finalConfirmText = confirmText ?? 'Bekræft';
    if (!infoDialog && cancelText == null) {
      finalCancelText = 'Annuller';
    }

    return AlertDialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: kBackgroundColor,
      scrollable: true,
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: title.isNotEmpty
          ? Text(
              title,
              style: _titleText,
              textAlign: TextAlign.center,
            )
          : null,
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: widgetContent ??
            Text(
              message,
              textAlign: TextAlign.center,
            ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              onlyAction
                  ? const SizedBox.shrink()
                  : Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          // height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue[300],
                              padding: const EdgeInsets.all(12),
                            ),
                            child: Text(
                              finalCancelText,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                    ),
              infoDialog
                  ? const SizedBox.shrink()
                  : Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: confirmColor ?? Colors.red,
                            padding: const EdgeInsets.all(12),
                          ),
                          child: Text(
                            finalConfirmText,
                          ),
                          onPressed: () => myOnPressed != null ? myOnPressed!() : null,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

// class MyLoadingDialog extends StatelessWidget {
//   const MyLoadingDialog({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return const Dialog(
//       insetPadding: EdgeInsets.zero,
//       elevation: 0,
//       backgroundColor: Colors.black45,
//       child: Center(child: SizedBox(width: 80, height: 80, child: CircularProgressIndicator())),
//     );
//   }
// }

Future<T?> showMyDialog<T>(
  BuildContext context,
  String title,
  String message, {
  String? cancelText,
  String? confirmText,
  void Function()? myOnPressed,
  bool infoDialog = true,
  bool onlyAction = false,
  Widget? widgetContent,
  BuildContext? specificContext,
  bool barrierDismissible = true,
  Color? confirmColor,
}) {
  return showDialog<T>(
    barrierDismissible: barrierDismissible,
    context: context,
    builder: (context) {
      specificContext = context;
      return MyAlertDialog(
        title: title,
        cancelText: cancelText,
        confirmText: confirmText,
        infoDialog: infoDialog,
        onlyAction: onlyAction,
        message: message,
        myOnPressed: myOnPressed,
        widgetContent: widgetContent,
        confirmColor: confirmColor,
      );
    },
  );
}

// void showMyLoadingDialog(BuildContext context) {
//   showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (context) {
//         return const MyLoadingDialog();
//       });
// }

// Future<T?> reauthenticateDialog<T>(
//   BuildContext context,
//   String confirmText,
//   void Function(String message) errorCallback,
// ) async {
//   final ValidateValues validateValues = ValidateValues();
//   final formKey = GlobalKey<FormState>();
//   String? password;
//   var appAuthState = context.read<AuthAppState>();
//   // String? _email;
//   // UserCredential? authCredential;
//   return await showMyDialog(context, 'Skriv dit password', '',
//       infoDialog: false,
//       barrierDismissible: false,
//       confirmText: confirmText,
//       widgetContext: Form(
//         key: formKey,
//         child: SizedBox(
//           width: MediaQuery.of(context).size.width,
//           child: Column(children: [
//             MyTextFieldWidget(
//               icon: const Icon(Icons.lock),
//               labelText: 'Password',
//               isRequired: false,
//               obscureText: true,
//               setValue: (value) => password = value,
//               validate: (value) => validateValues.validatePassword(value),
//             ),
//           ]),
//         ),
//       ), myOnPressed: () async {
//     if (formKey.currentState!.validate()) {
//       formKey.currentState!.save();
//       var authCredential = EmailAuthProvider.credential(email: appAuthState.currentUser!.email ?? '', password: password!);
//       await appAuthState.reauthenticateUser(authCredential).then((result) {
//         if (result == null) {
//           Navigator.pop(context, 'Success');
//         } else {
//           Navigator.pop(context, result);
//         }
//       });
//     }
//   });
// }