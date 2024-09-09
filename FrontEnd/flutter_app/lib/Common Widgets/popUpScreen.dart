import 'package:flutter/material.dart';

class popUpScreen extends StatelessWidget {
  final String popUpText;
  final Function onConfirmed;

  const popUpScreen({
    Key? key,
    required this.popUpText,
    required this.onConfirmed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          '$popUpText',
          textAlign: TextAlign.center,
        ),
      ),
      backgroundColor: Color(0xff381A57).withOpacity(0.7),
      titleTextStyle: Theme.of(context).textTheme.titleMedium,
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.10,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 40,
              width: 254,
              child: ElevatedButton(
                child: Text(
                  "Yes",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                onPressed: () {
                  onConfirmed();
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(
                    const Color.fromRGBO(136, 69, 205, 1),
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
              ),
            ),
            SizedBox(
              height: 40,
              width: 254,
              child: ElevatedButton(
                child: Text(
                  "No",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(
                    const Color.fromRGBO(136, 69, 205, 1),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showPopUp(BuildContext context, String popUpText, Function onConfirmed) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return popUpScreen(
        popUpText: popUpText,
        onConfirmed: onConfirmed,
      );
    },
  );
}
