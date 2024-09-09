import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final signInProvider = StateProvider<bool>((ref) => false);

class SignInButton extends ConsumerStatefulWidget {
  final Function onClicked;
  const SignInButton({
    Key? key,
    required this.onClicked,
  }) : super(key: key);

  @override
  _SignInButtonState createState() => _SignInButtonState();
}

class _SignInButtonState extends ConsumerState<SignInButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 254,
      child: ElevatedButton(
        onPressed: ()  {
          widget.onClicked();
        },
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(
            ref.watch(signInProvider.notifier).state
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
        child: const Text("Sign In"),
      ),
    );
  }
}
