import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/features/tournament_managment/controller/tournament_provider.dart';
import 'package:iron_sight/models/tournament.dart';

final loadingProvider =
    StateNotifierProvider.autoDispose<LoadingNotifier, bool>((ref) {
  return LoadingNotifier(); // Initialize the notifier
});

class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false); // Initialize with false

  void setLoading(bool isLoading) {
    state = isLoading; // Update the state
  }
}

class MatchCard extends ConsumerStatefulWidget {
  final bool isAdmin;
  final Player playerOne;
  final Player playerTwo;
  final bool isMatchActive;

  const MatchCard({
    Key? key,
    required this.isAdmin,
    required this.playerOne,
    required this.playerTwo,
    required this.isMatchActive,
  }) : super(key: key);
  @override
  _MatchCardState createState() => _MatchCardState();
}

class _MatchCardState extends ConsumerState<MatchCard> {
  @override
  Widget build(BuildContext context) {
    // final isLoading = ref.watch(loadingProvider);
    // print('isloaindg is loading $isLoading');
    return Padding(
      key: ValueKey(widget.playerOne.id + widget.playerTwo.id),
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: ShapeDecoration(
          color: const Color.fromARGB(115, 116, 24, 214),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    color: widget.isMatchActive
                        ? const Color.fromARGB(255, 94, 212, 98) // Active color
                        : Colors.red, // Ended color
                    size: 20,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    widget.isMatchActive
                        ? 'Active'
                        : 'Ended', // Display status based on the match state
                    style: Theme.of(context).textTheme.titleMedium!,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: InkWell(
                onTap: !widget.isMatchActive
                    ? null
                    : () {
                        if (widget.isAdmin) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Center(child: Text('Who Won?')),
                                backgroundColor:
                                    const Color(0xff381A57).withOpacity(0.7),
                                titleTextStyle: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                                content: Consumer(
                                  builder: (context, _ref, child) {
                                    final isLoading =
                                        _ref.watch(loadingProvider);
                                    return SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.20,
                                      child: Stack(children: [
                                        Column(
                                          children: [
                                            InkWell(
                                              onTap: isLoading
                                                  ? null
                                                  : () async {
                                                      // // Logic for choosing winners

                                                      try {
                                                        print(
                                                            'beginging the winning process');
                                                        ref
                                                            .read(
                                                                loadingProvider
                                                                    .notifier)
                                                            .setLoading(true);
                                                        await ref
                                                            .watch(
                                                                singleTournamentStateProvider
                                                                    .notifier)
                                                            .winMatch(widget
                                                                .playerOne.id);

                                                        ref
                                                            .read(
                                                                loadingProvider
                                                                    .notifier)
                                                            .setLoading(false);
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                SnackBar(
                                                          content: Text(
                                                              '${widget.playerOne.name} has won the match!'),
                                                          duration:
                                                              const Duration(
                                                                  seconds: 2),
                                                        ));

                                                        Navigator.of(context)
                                                            .pop();
                                                      } catch (e) {
                                                        ref
                                                            .read(
                                                                loadingProvider
                                                                    .notifier)
                                                            .setLoading(false);

                                                        // show error message
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                SnackBar(
                                                              content: Text(
                                                                  'Something went wrong! ${e.toString()}'),
                                                              duration:
                                                                  const Duration(
                                                                      seconds:
                                                                          2),
                                                            ))
                                                            .closed
                                                            .then((reason) {
                                                          Navigator.of(context)
                                                              .pop();
                                                        });
                                                      }
                                                    },
                                              child: Container(
                                                decoration: ShapeDecoration(
                                                  color:
                                                      const Color(0xff5B298F),
                                                  // color: Colors.red,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 5.0,
                                                      horizontal: 5),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        color:
                                                            Colors.transparent,
                                                        child: CircleAvatar(
                                                          backgroundImage:
                                                              NetworkImage(
                                                            widget.playerOne
                                                                .profileImage,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        widget.playerOne.name,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleSmall,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'vs',
                                              style: GoogleFonts.racingSansOne(
                                                textStyle: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontFamily: '',
                                                  fontWeight: FontWeight.w400,
                                                  letterSpacing: -0.8,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: isLoading
                                                  ? null
                                                  : () async {
                                                      //  print('sending!');
                                                      //   // Logic for choosing winners
                                                      //   ref
                                                      //       .read(loadingProvider.notifier)
                                                      //       .setLoading(true);
                                                      //   await Future.delayed(
                                                      //       const Duration(seconds: 2));
                                                      //   ref
                                                      //       .read(loadingProvider.notifier)
                                                      //       .setLoading(false);
                                                      // same logic but with the second player
                                                      try {
                                                        print(
                                                            'beginging the winning process');

                                                        ref
                                                            .read(
                                                                loadingProvider
                                                                    .notifier)
                                                            .setLoading(true);
                                                        await ref
                                                            .watch(
                                                                singleTournamentStateProvider
                                                                    .notifier)
                                                            .winMatch(widget
                                                                .playerTwo.id);

                                                        ref
                                                            .read(
                                                                loadingProvider
                                                                    .notifier)
                                                            .setLoading(false);
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                SnackBar(
                                                          content: Text(
                                                              '${widget.playerTwo.name} has won the match!'),
                                                          duration:
                                                              const Duration(
                                                                  seconds: 2),
                                                        ));

                                                        Navigator.of(context)
                                                            .pop();
                                                      } catch (e) {
                                                        ref
                                                            .read(
                                                                loadingProvider
                                                                    .notifier)
                                                            .setLoading(false);

                                                        // show error message
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                SnackBar(
                                                              content: Text(
                                                                  'Something went wrong! ${e.toString()}'),
                                                              duration:
                                                                  const Duration(
                                                                      seconds:
                                                                          2),
                                                            ))
                                                            .closed
                                                            .then((reason) {
                                                          Navigator.of(context)
                                                              .pop();
                                                        });
                                                      }
                                                    },
                                              child: Container(
                                                decoration: ShapeDecoration(
                                                  color:
                                                      const Color(0xff5B298F),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 5.0,
                                                      horizontal: 5),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        color:
                                                            Colors.transparent,
                                                        child: CircleAvatar(
                                                          backgroundImage:
                                                              NetworkImage(
                                                            widget.playerTwo
                                                                .profileImage,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        widget.playerTwo.name,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleSmall,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (isLoading)
                                          const Center(
                                              child: CustomProgressIndicator()),
                                      ]),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        }
                      },
                child: Center(
                  child: Container(
                    decoration: ShapeDecoration(
                      color: const Color.fromARGB(248, 44, 0, 72),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(children: [
                            Container(
                              width: 50,
                              height: 50,
                              color: Colors.transparent,
                              child: CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                  widget.playerOne.profileImage,
                                ),
                              ),
                            ),
                            if (widget.playerOne.status == "Winner" &&
                                !widget.isMatchActive)
                              Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Icon(
                                    Icons.star,
                                    size: 24,
                                    color: Colors.amber[600],
                                  ))
                          ]),
                          Container(
                            color: Colors.transparent,
                            child: Text(
                              'VS',
                              style: GoogleFonts.racingSansOne(
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontFamily: '',
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.8,
                                ),
                              ),
                            ),
                          ),
                          Stack(children: [
                            Container(
                              width: 50,
                              height: 50,
                              color: Colors.transparent,
                              child: CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                  widget.playerTwo.profileImage,
                                ),
                              ),
                            ),
                            if (widget.playerTwo.status == "Winner" &&
                                !widget.isMatchActive)
                              Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Icon(
                                    Icons.star,
                                    size: 24,
                                    color: Colors.amber[600],
                                  ))
                          ]),
                        ],
                      ),
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
