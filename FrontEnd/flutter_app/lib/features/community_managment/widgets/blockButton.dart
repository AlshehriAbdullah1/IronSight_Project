import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/Common%20Widgets/popUpScreen.dart';
import 'package:iron_sight/features/community_managment/controller/member_provider.dart';

class ButtonState {
  ButtonState(this.text, this.color);
  String text;
  Color color;
}

final buttonStateProvider = StateProvider.family<ButtonState, String>(
    (ref, id) => ButtonState("Unblock", const Color.fromRGBO(136, 69, 205, 1)));

class BlockButton extends ConsumerWidget {
  final String memberId;
  final String community_id;

  BlockButton({
    Key? key,
    required this.memberId,
    required this.community_id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buttonState = ref.read(buttonStateProvider(memberId));
    return SizedBox(
      height: 35,
      width: 85,
      child: ElevatedButton(
        onPressed: () => _onButtonPressed(context, ref),
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(buttonState.color),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        ),
        child: Text(
          buttonState.text,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
    );
  }

  void _onButtonPressed(BuildContext context, WidgetRef ref) {
    final buttonText =
        ref.read(buttonStateProvider(memberId)).text.toLowerCase();
    final message = buttonText.toLowerCase() == "unblock"
        ? "Are you sure you want to unblock this user"
        : "Are you sure you want to block this user";
    final errorMessage = buttonText.toLowerCase() == "unblock"
        ? 'Failed to unblock this user'
        : 'Failed to block this user';

    showPopUp(context, message, () async {
        bool? response;
      if(buttonText.toLowerCase() == "unblock"){
           response = await ref
          .read(blockedMembersStateProvider.notifier)
          .unblockMember(memberId, community_id);
      }
      else{
           response = await ref
          .read(blockedMembersStateProvider.notifier)
          .blockMember(memberId, context);
      }
      
      try {
        if (response != null && response) {
          final newButtonText = buttonText == "unblock" ? "Block" : "Unblock";
          final newButtonColor = buttonText == "unblock"
              ? const Color.fromRGBO(91, 41, 143, 1)
              : const Color.fromRGBO(136, 69, 205, 1);
          ref.read(buttonStateProvider(memberId).notifier).state =
              ButtonState(newButtonText, newButtonColor);
        }
      } catch (e) {
        _showErrorSnackBar(context, errorMessage);
      }
    });
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:iron_sight/Common%20Widgets/popUpScreen.dart';
// import 'package:iron_sight/features/community_managment/controller/member_provider.dart';

// class BlockButton extends ConsumerStatefulWidget {
//   final String memberId;
//   final String community_id;

//   BlockButton({
//     Key? key,
//     required this.memberId,
//     required this.community_id,
//   }) : super(key: key);

//   @override
//   ConsumerState<BlockButton> createState() => _BlockButtonState();
// }

// final buttonColorProvider =
//     StateProvider<Color>((ref) => const Color.fromRGBO(136, 69, 205, 1));
// final buttonTextProvider = StateProvider<String>((ref) => "Unblock");

// class _BlockButtonState extends ConsumerState<BlockButton> {
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 35,
//       width: 85,
//       child: ElevatedButton(
//         onPressed: () => _onButtonPressed(context),
//         style: ButtonStyle(
//           padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
//             const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
//           ),
//           backgroundColor: MaterialStateProperty.all<Color>(
//             ref.watch(buttonColorProvider),
//           ),
//           foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
//         ),
//         child: Text(
//           ref.watch(buttonTextProvider),
//           style: Theme.of(context).textTheme.titleSmall,
//         ),
//       ),
//     );
//   }

//   void _onButtonPressed(BuildContext context) {
//     final buttonText =
//         ref.read(buttonTextProvider.notifier).state.toLowerCase();
//     final message = buttonText == "unblock"
//         ? "Are you sure you want to unblock this user"
//         : "Are you sure you want to block this user";
//     final newButtonText = buttonText == "unblock" ? "Block" : "Unblock";
//     final newButtonColor = buttonText == "unblock"
//         ? const Color.fromRGBO(91, 41, 143, 1)
//         : const Color.fromRGBO(136, 69, 205, 1);
//     final errorMessage = buttonText == "unblock"
//         ? 'Failed to unblock this user'
//         : 'Failed to block this user';

//     showPopUp(context, message, () async {
//       final response = await ref
//           .read(blockedMembersStateProvider.notifier)
//           .unblockMember(widget.memberId, widget.community_id);
//       try {
//         if (response != null && response) {
//           ref.read(buttonTextProvider.notifier).state = newButtonText;
//           ref.read(buttonColorProvider.notifier).state = newButtonColor;
//         }
//       } catch (e) {
//         _showErrorSnackBar(context, errorMessage);
//       }
//     });
//   }

//   void _showErrorSnackBar(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }
// }
// class _BlockButtonState extends ConsumerState<BlockButton> {
//   final buttonColorProvider =
//       StateProvider<Color>((ref) =>const Color.fromRGBO(136, 69, 205, 1));
//   final buttonTextProvider = StateProvider<String>((ref) => "Unblock");

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () {
//         if (ref.read(buttonTextProvider.notifier).state.toLowerCase() ==
//             "unblock") {
              
//           // ref.read(buttonTextProvider.notifier).state = "Block";
//           showPopUp(context, "Are you sure you want to unblock this user",
//               () async{
//                   final response=  await ref.read(membersStateProvider.notifier).unblockMember(widget.memberId,widget.community_id);
//                   try {
//                     if(response != null && response){
//                       // change the state of buttonTextProvider
//                       ref.read(buttonTextProvider.notifier).state = "block";
//                       ref.read(buttonColorProvider.notifier).state =
//                           const Color.fromRGBO(91, 41, 143, 1);
//                   }
//                   } catch (e) {
//                    //show the user error message 
//                    ScaffoldMessenger.of(context).showSnackBar(
//   const SnackBar(
//     content: Text('Failed to unblock this user'),
//     backgroundColor: Colors.red,
//   ),
// );

                    
//                   }
                  
    
//           });
//           ref.read(buttonColorProvider.notifier).state =
//               const Color.fromRGBO(91, 41, 143, 1);
         
//         } else if (ref
//                 .read(buttonTextProvider.notifier)
//                 .state
//                 .toLowerCase() ==
//             'block') {
//                showPopUp(context, "Are you sure you want to unblock this user",
//               () async{
//                   final response=  await ref.read(membersStateProvider.notifier).unblockMember(widget.memberId,widget.community_id);
//                   try {
//                     if(response != null && response){
//                       // change the state of buttonTextProvider
//                       ref.read(buttonTextProvider.notifier).state = "Unblock";
//                       ref.read(buttonColorProvider.notifier).state =
//                           const Color.fromRGBO(136, 69, 205, 1);
//                   }
//                   } catch (e) {
//                    //show the user error message 
//                    ScaffoldMessenger.of(context).showSnackBar(
//   const SnackBar(
//     content: Text('Failed to block this user'),
//     backgroundColor: Colors.red,
//   ),
// );

                    
//                   }
                  
    
//           });
//               // call the block function
//             }
//       },
//       style: ButtonStyle(
//         // Set horizontal and vertical padding
//         padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
//           const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
//         ),
//         // Change background color
//         backgroundColor: MaterialStateProperty.all<Color>(
//           ref.watch(
//               buttonColorProvider), // Replace with your preferred background color
//         ),
//         // Change foreground (text) color
//         foregroundColor: MaterialStateProperty.all<Color>(
//           Colors.white, // Replace with your preferred text color
//         ),
//       ),
//       child: Text(
//         ref.watch(buttonTextProvider),
//         style: Theme.of(context).textTheme.titleSmall,
//       ),
//     );
//   }
// }
