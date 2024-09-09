import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/APIs/user_api_client.dart';
import 'package:iron_sight/Common%20Widgets/regularFollowButton.dart';
import 'package:iron_sight/features/tournament_managment/controller/tournament_provider.dart';
import 'package:iron_sight/features/user_managment/controller/user_provider.dart';
import 'package:iron_sight/models/tournament.dart';

class TournamentCard extends ConsumerStatefulWidget {
  final String tournamentImage;
  final String tournamentName;
  final String tournamentId;
  final String tournamentDescription;
  final Tournament tournament;

  const TournamentCard({
    Key? key,
    required this.tournamentImage,
    required this.tournamentName,
    required this.tournamentDescription,
    required this.tournamentId,
    required this.tournament,
  }) : super(key: key);

  @override
  _TournamentCardState createState() => _TournamentCardState();
}

class _TournamentCardState extends ConsumerState<TournamentCard> {
  @override
  Widget build(BuildContext context) {
    final tournamentList = ref.watch(tournamentListStateProvider);
    final userState = ref.watch(userProvider);
    final isFollowing = ref
        .watch(tournamentListStateProvider.notifier)
        .isUserFollowingTournament(widget.tournamentId);
    final isOwner = ref
        .watch(tournamentListStateProvider.notifier)
        .isOwner(widget.tournamentId);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        width: 390.0,
        child: Card(
          color: const Color(0xFF50188B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 114.0,
                  height: 174.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        5.0), // Adjust the value as needed
                    image: DecorationImage(
                      image: NetworkImage(
                        widget.tournamentImage,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.tournamentName,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      Text(
                      widget.tournamentDescription,
                        style: Theme.of(context).textTheme.bodyLarge,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),
                      // CommunityFollowButton(tournamentId: widget.tournamentId),
                      if (!isOwner)
                        Column(
                          children: [
                            SizedBox(
                              height: 35,
                              width: 200,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (isFollowing) {
                                    try {
                                      await ref
                                          .read(userProvider.notifier)
                                          .unfollowTournament(
                                              widget.tournament);
                                    } catch (e) {
                                      // Scaffold messanger

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(
                                          e.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ));
                                    }
                                  } else {
                                    try {
                                      await ref
                                          .read(userProvider.notifier)
                                          .followTournament(widget.tournament);
                                    } catch (e) {
                                      // Scaffold messanger

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(
                                          e.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ));
                                    }
                                  }
                                },
                                style: ButtonStyle(
                                  // Set horizontal and vertical padding
                                  padding: MaterialStateProperty.all<
                                      EdgeInsetsGeometry>(
                                    const EdgeInsets.symmetric(
                                        horizontal: 0, vertical: 0),
                                  ),
                                  // Change background color
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    isFollowing
                                        ? const Color.fromRGBO(91, 41, 143, 1)
                                        : const Color.fromRGBO(136, 69, 205,
                                            1), // Replace with your preferred background color
                                  ),
                                  // Change foreground (text) color
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Colors
                                        .white, // Replace with your preferred text color
                                  ),
                                ),
                                child: Text(
                                  isFollowing ? 'Unfollow' : 'Follow',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),

                      //need to improve
                      if (isOwner)
                        Container(
                          child: Text('You Are The Owner'),
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
