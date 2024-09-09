import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/features/tournament_managment/controller/tournament_provider.dart';
import 'package:iron_sight/features/tournament_managment/views/tournament_management_view.dart';
import 'package:iron_sight/features/tournament_managment/widgets/tournament_card.dart';

class TournamentsSearch extends ConsumerStatefulWidget {
  const TournamentsSearch({Key? key}) : super(key: key);

  @override
  _TournamentsSearchState createState() => _TournamentsSearchState();
}

class _TournamentsSearchState extends ConsumerState<TournamentsSearch> {
  @override
  void initState() {
    super.initState();
     Future(() {
    ref.read(tournamentListStateProvider.notifier).loadTournaments(isHomeView: true);
  });
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(tournamentListStateProvider).when(
      data: (TournamentsSearch) {
        if (TournamentsSearch.isEmpty) {
          return const Center(
            child: Text('No tournaments to display'),
          );
        } else {
          return RefreshIndicator(
            onRefresh: () async{
               ref.read(tournamentListStateProvider.notifier).loadTournaments(isHomeView: true);
            },
            child: ListView(
              padding: const EdgeInsets.only(top: 10),
              children: [
                ...TournamentsSearch.map((tournament) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>  TournamentManagementView(tournamentId:  tournament.id,
                                        
                                        )),
                          );
                    },
                    child: TournamentCard(
                        tournamentImage:  tournament.thumbnail,
                        tournamentName: tournament.tournamentName,
                        tournamentDescription: tournament.description,
                        tournamentId: tournament.id,
                        tournament: tournament,),
                  );
                })
              ],
            ),
          );
        }
      },
      loading: () => const Center(child: CustomProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error:$error: $stack')),
    );
  }
}