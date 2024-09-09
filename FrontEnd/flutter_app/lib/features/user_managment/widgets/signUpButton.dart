import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final signUpProvider = StateProvider<bool>((ref) => false);

class SignUpButton extends ConsumerStatefulWidget {
  final Function onClicked;
  const SignUpButton({
    Key? key,
    required this.onClicked,
  }) : super(key: key);

  @override
  _SignUpButtonState createState() => _SignUpButtonState();
}

class _SignUpButtonState extends ConsumerState<SignUpButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 254,
      child: ElevatedButton(
        onPressed: () async {
        },
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(
            ref.watch(signUpProvider.notifier).state
                ? const Color.fromRGBO(91, 41, 143, 1)
                : const Color.fromRGBO(136, 69, 205, 1),
          ),
          foregroundColor: MaterialStateProperty.all<Color>(
            Colors.white,
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
        ),
        child: Text("Sign Up"),
      ),
    );
  }
}
