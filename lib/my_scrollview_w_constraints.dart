import 'package:flutter/material.dart';

import '../res/value_constants.dart';

class MyScrollviewWConstraints extends StatelessWidget {
  final Widget child;
  const MyScrollviewWConstraints({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
      child: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kMaxWidth),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
