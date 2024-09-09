import 'package:flutter/material.dart';
import 'package:iron_sight/Common%20Widgets/popUpScreen.dart';

class regularFollowButton extends StatefulWidget {
  final Function onClicked;
  const regularFollowButton({
    Key? key,
    required this.onClicked,
  }) : super(key: key);

  @override
  State<regularFollowButton> createState() => _regularFollowButtonState();
}

class _regularFollowButtonState extends State<regularFollowButton> {
  Color buttoncolor = Color.fromRGBO(136, 69, 205, 1);
  String buttonText = "Follow";

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      width: 250,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            if (buttonText == "Follow") {
              widget.onClicked();
              buttonText = "Followed";
              buttoncolor = const Color.fromRGBO(91, 41, 143, 1);
            } else {
              showPopUp(context, "Are you sure you want to unfollow", () {
                setState(() {
                  buttoncolor = const Color.fromRGBO(136, 69, 205, 1);
                  buttonText = "Follow";
                });
              });
            }
          });
        },
        style: ButtonStyle(
          // Set horizontal and vertical padding
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          ),
          // Change background color
          backgroundColor: MaterialStateProperty.all<Color>(
            buttoncolor, // Replace with your preferred background color
          ),
          // Change foreground (text) color
          foregroundColor: MaterialStateProperty.all<Color>(
            Colors.white, // Replace with your preferred text color
          ),
        ),
        child: Text(
          buttonText,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
    );
  }
}
