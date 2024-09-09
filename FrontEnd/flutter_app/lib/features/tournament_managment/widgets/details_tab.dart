import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/features/tournament_managment/controller/tournament_provider.dart';
import 'package:iron_sight/features/tournament_managment/widgets/register_button.dart';
import 'package:iron_sight/features/tournament_managment/widgets/start_tournament_button.dart';
import 'package:iron_sight/features/user_managment/controller/auth_provider.dart';
import 'package:iron_sight/models/tournament.dart';
import 'package:linkable/linkable.dart';
import 'package:flutter/material.dart';
import 'package:iron_sight/features/tournament_managment/widgets/avatarInlist.dart';

final inHouseProvider = StateProvider<bool>((ref) => true);

// final participantsInfoProvider = FutureProvider.autoDispose<List<Participant>>((ref) async {
//   final tournamentProvider = ref.watch(singleTournamentStateProvider.notifier);
//   return await tournamentProvider.updateParticipantsInfo();
// });
class details_tab extends ConsumerStatefulWidget {
  List<Participant> participants;
  String description;
  String prizePool;
  String date;
  String streamingLink;
  
  int maxParticipants;
  bool isStarted;
  String result;

  details_tab(
      {super.key,
      required this.participants,
      required this.description,
      required this.prizePool,
      required this.date,
      required this.streamingLink,
      required this.maxParticipants,
      required this.isStarted,
      required this.result});

  @override
  ConsumerState<details_tab> createState() => _details_tabState();
}

class _details_tabState extends ConsumerState<details_tab> {
  final bool inHouse = true;
  late Future<List<Participant>> _updateParticipantsFuture;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // inHouse = ref.read(inHouseProvider.notifier).state;

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      // inHouse = ref.read(inHouseProvider.notifier).state;
      //  ref.read(singleTournamentStateProvider.notifier).updateParticipantsInfo();
      //  ref.watch(singleTournamentStateProvider.notifier).updateParticipantsInfo();
    });

    //  Future(() {
    //   _updateParticipantsFuture= ref.read(singleTournamentStateProvider.notifier).updateParticipantsInfo();
    //  });
    // });
  }

  @override
  Widget build(BuildContext context) {
    final tournament = ref.watch(singleTournamentStateProvider);
    final isOwner = ref.read(singleTournamentStateProvider.notifier).isOwner();

    return buildParticipantsTab(widget.participants, isOwner);
  }

  Widget buildParticipantsTab(List<Participant> participants, bool isOwner) {
    List<DataRow> participantsRows = [];

    for (var participant in participants) {
      participantsRows.add(DataRow(cells: [
        DataCell(
          avatarInlist(
            playerName: participant.participantName,
            playerAccount: participant.participantUserName,
            playerId: participant.participantId,
            avatar: participant.participantImage != null
                ? CachedNetworkImageProvider(participant.participantImage!)
                : const AssetImage("assets/avatar.jpg") as ImageProvider,
          ),
        ),
        DataCell(
          Center(
            child: Text(
              participant.record.wins.toString(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              participant.record.losses.toString(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      ]));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              if (inHouse)
                ExpansionTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  childrenPadding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  title: Text(
                    " Participants: ${participants.length.toString()}/${widget.maxParticipants}",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ParticipantsTable(participants: participants),
                      ],
                    )
                  ],
                ),
              ExpansionTile(
                controlAffinity: ListTileControlAffinity.leading,
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                childrenPadding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                title: Text(
                  "Description",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          widget.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Prize pool:",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              widget.prizePool.toString(),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Streaming Link:",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Linkable(
                              text: widget.streamingLink,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  children: [
                    RegisterButton(
                      particiapants: participants,
                    ),
                       const SizedBox(height: 10),
                       if (isOwner)
                      StartTournamentButton(isStarted: widget.isStarted,isFull: widget.participants.length == widget.maxParticipants
                      ,isEnded: widget.result.toLowerCase()!='pending',),
                    const SizedBox(height: 10),
                    Text(
                      "Registration closes at ${widget.date}",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                 

                    // const StartTournamentButton(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                  ],
                ),
              )
              // Rest of the UI code...
            ],
          ),
        ],
      ),
    );
  }
}

class ParticipantsTable extends StatefulWidget {
  List<Participant> participants;

  ParticipantsTable({required this.participants});

  @override
  State<ParticipantsTable> createState() => _ParticipantsTableState();
}

class _ParticipantsTableState extends State<ParticipantsTable> {
  @override
  Widget build(BuildContext context) {
    return DataTable(
      horizontalMargin: 0,
      columns: [
        DataColumn(
            onSort: (columnIndex, ascending) {
              setState(() {
                widget.participants = List.from(widget.participants)
                  ..sort((a, b) {
                    if (ascending) {
                      return a.participantName.compareTo(b.participantName);
                    } else {
                      return b.participantName.compareTo(a.participantName);
                    }
                  });
              });
            },
            label: const Text('Player')),
        DataColumn(
            onSort: (columnIndex, ascending) {
              setState(() {
                widget.participants = List.from(widget.participants)
                  ..sort((a, b) {
                    if (ascending) {
                      return a.record.wins.compareTo(b.record.wins);
                    } else {
                      return b.record.wins.compareTo(a.record.wins);
                    }
                  });
              });
            },
            label: const Text('Wins')),
        DataColumn(
            onSort: (columnIndex, ascending) {
              setState(() {
                widget.participants = List.from(widget.participants)
                  ..sort((a, b) {
                    if (ascending) {
                      return a.record.losses.compareTo(b.record.losses);
                    } else {
                      return b.record.losses.compareTo(a.record.losses);
                    }
                  });
              });
            },
     label: const Flexible( 
    child: Text('Losses'),
  ),
  ),
      ],
      rows: widget.participants
          .map((participant) => DataRow(
                cells: [
                  DataCell(
                    avatarInlist(
                      key: ValueKey(participant.participantId),
                      playerName: participant.participantName.length > 10
                          ? '${participant.participantName.substring(0, 10)}...'
                          : participant.participantName,
                      playerAccount: participant.participantUserName.length > 10
                          ? '${participant.participantUserName.substring(0, 10)}...'
                          : participant.participantUserName,
                      playerId: participant.participantId,
                      avatar: participant.participantImage != null
                          ? CachedNetworkImageProvider(
                              participant.participantImage!)
                          : const AssetImage("assets/avatar.jpg")
                              as ImageProvider,
                    ),
                  ),
                  DataCell(
                    Center(
                      child: Text(
                        participant.record.wins.toString(),
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ),
                  DataCell(
                    Center(
                      child: Text(
                        participant.record.losses.toString(),
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ),
                ],
              ))
          .toList(),
    );
  }
}
