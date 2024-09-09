import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/Common%20Widgets/popUpScreen.dart';

class smallFollowButton extends ConsumerStatefulWidget {
  final Function onClicked;
   bool isFollowing;
   smallFollowButton({
    Key? key,
    required this.onClicked,
     this.isFollowing=false,
  }) : super(key: key);

  @override
  ConsumerState<smallFollowButton> createState() => _smallFollowButtonState();
}

class _smallFollowButtonState extends ConsumerState<smallFollowButton> {
  final buttonColorProvider =
      StateProvider<Color>((ref) =>const Color.fromRGBO(136, 69, 205, 1));

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      width: 85,
      child: ElevatedButton(
        onPressed: () {
          if (!widget.isFollowing) {
           
            
            ref.read(buttonColorProvider.notifier).state =
                const Color.fromRGBO(91, 41, 143, 1);
                widget.onClicked();
                
          } else {
            showPopUp(context, "Are you sure you want to unfollow", () {
              ref.read(buttonColorProvider.notifier).state =
                  const Color.fromRGBO(136, 69, 205, 1);
               widget.onClicked();
            });
          }
         
        },
        style: ButtonStyle(
          // Set horizontal and vertical padding
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          ),
          // Change background color
          backgroundColor: MaterialStateProperty.all<Color>(
            ref.watch(
                buttonColorProvider), // Replace with your preferred background color
          ),
          // Change foreground (text) color
          foregroundColor: MaterialStateProperty.all<Color>(
            Colors.white, // Replace with your preferred text color
          ),
        ),
        child: Text(
          widget.isFollowing?'Unfollow':'Follow' ,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
    );
  }
}
