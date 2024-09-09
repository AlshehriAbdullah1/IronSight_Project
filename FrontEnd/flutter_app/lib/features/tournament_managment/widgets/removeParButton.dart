import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/Common%20Widgets/popUpScreen.dart';
import 'package:iron_sight/features/tournament_managment/controller/tournament_provider.dart';

class removeParButton extends ConsumerWidget {
  final String playerId;
  const removeParButton({required this.playerId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CircleAvatar(
        radius: 10,
        backgroundColor: Colors.red,
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(
            Icons.remove_circle_outline_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            showPopUp(context,
                "Are you sure you want to remove this user from the tournament",
                () async {
              final response = await ref
                  .read(singleTournamentStateProvider.notifier)
                  .removeParticipant(playerId);
              // if (response != null) {
              //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              //     content: Text('Participant removed successfully'),
              //     duration: Duration(seconds: 2),
              //   ));
              // }
            });
          },
        ));
  }
}
