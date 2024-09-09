import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/features/tournament_managment/widgets/match_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/features/tournament_managment/controller/tournament_provider.dart';

class MatchesTab extends ConsumerStatefulWidget {


  const MatchesTab({
    Key? key,
    
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MatchesTabState();
}
class _MatchesTabState extends ConsumerState<MatchesTab> {

 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ref.read(singleTournamentStateProvider.notifier).getMatches();
  }
  
  @override
Widget build(BuildContext context) {
  final tournamentMatches = ref.watch(singleTournamentStateProvider);
  final isTourOrg = ref.read(singleTournamentStateProvider.notifier).isOwner();
  return SingleChildScrollView(
    child: tournamentMatches.when(
      data: (data) {
        List<MatchCard> activeMatches = [];
        List<MatchCard> endedMatches = [];
        for (var match in data.matches.active) {
          activeMatches.add(MatchCard(
            isAdmin: isTourOrg,
            playerOne: match.player1,
            playerTwo: match.player2,
            isMatchActive: true,
          ));
        }
        for (var match in data.matches.ended) {
          endedMatches.add(MatchCard(
            isAdmin: isTourOrg,
            playerOne: match.player1,
            playerTwo: match.player2,
            isMatchActive: false,
          ));
        }
        return Column(children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Active Matches", style: Theme.of(context).textTheme.titleMedium)),
          ...activeMatches,
          const SizedBox(height: 50),
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Ended Matches", style: Theme.of(context).textTheme.titleMedium),
          ),
          ...endedMatches,
        ]);
      },
      error: (error, stackTrace) {
        return const Center(child: Text("Error occurred while loading matches"));
      },
      loading: () {
        return const CustomProgressIndicator();
      },
    ),
  );
}
}
