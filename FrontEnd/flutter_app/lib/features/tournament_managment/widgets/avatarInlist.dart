import 'package:flutter/material.dart';
import 'package:iron_sight/features/tournament_managment/widgets/removeParButton.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/features/tournament_managment/controller/tournament_provider.dart';

class avatarInlist extends StatelessWidget {
  final String playerName;
  final String playerAccount;
  final ImageProvider avatar;
  final String playerId;

  const avatarInlist({
    Key? key,
    required this.playerName,
    required this.playerAccount,
    required this.playerId,
    required this.avatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Consumer(builder: (context, ref, child) {
          final isOwner = ref.read(singleTournamentStateProvider.notifier).isOwner();
       
          return isOwner
              ? removeParButton(
                  playerId: playerId,
                )
              : const SizedBox();
        }),
       
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: CircleAvatar(
            backgroundImage: avatar,
            radius: 25,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(playerName, style: Theme.of(context).textTheme.bodyLarge),
            Text(playerAccount, style: Theme.of(context).textTheme.labelMedium),
          ],
        )
      ],
    );
  }
}
