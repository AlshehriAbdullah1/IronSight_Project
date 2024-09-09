import 'package:flutter/material.dart';
import 'package:iron_sight/Common%20Widgets/regular_CustomTextfieldForm.dart';

final TextEditingController _PasswordController = TextEditingController();

class PasswordPopUp extends StatelessWidget {
  final String popUpText = 'Please Enter The Community Password';
  final Function onConfirmed;

  const PasswordPopUp({
    Key? key,
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
        height: MediaQuery.of(context).size.height * 0.15,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             SizedBox(
                height: 1,
            ),
            CustomTextFormField(
                  controller: _PasswordController,
                  hintText: 'Password',
                  onSaved: (p0) {},
                  prefixIcon: Icons.key,
                  obscureText: true,
                ),
            SizedBox( height: 1,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [ElevatedButton(
                  onPressed: () {
                    onConfirmed();
                    Navigator.of(context).pop();
                  },
                  child: Text('Confirm'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                
          ],
        ),
      ]),
    ));
  }
}

void showPopUp(BuildContext context, String popUpText, Function onConfirmed) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return PasswordPopUp(
        onConfirmed: onConfirmed,
      );
    },
  );
}
