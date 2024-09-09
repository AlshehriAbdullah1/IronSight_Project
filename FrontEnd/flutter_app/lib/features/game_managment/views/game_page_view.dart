import 'package:flutter/material.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/Common%20Widgets/TournamentInfoCard.dart';
import 'package:iron_sight/Common%20Widgets/MainPage.dart';
import 'package:iron_sight/Common%20Widgets/communityCard.dart';
import 'package:iron_sight/Common%20Widgets/popUpScreen.dart';
import 'package:iron_sight/Common%20Widgets/reportForm.dart';
import 'package:iron_sight/Common%20Widgets/smallFollowButton.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/features/game_managment/controller/game_provider.dart';
import 'package:iron_sight/models/game.dart';

import '../../tournament_managment/controller/tournament_provider.dart';
import '../../tournament_managment/views/tournament_management_view.dart';
import '../../tournament_managment/widgets/tournament_card.dart';

final adminProvider = StateProvider<bool>((ref) => true);

class GamePageView extends ConsumerStatefulWidget {
  final Game game;
  const GamePageView({super.key, required this.game});

  @override
  ConsumerState<GamePageView> createState() => _GamePageViewState();
}

class _GamePageViewState extends ConsumerState<GamePageView>
    with SingleTickerProviderStateMixin {
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  late TabController _tabController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // ref.read(gameStateProvider.notifier).getGame("9nJCoMKSLFFBxe67GSnW");
  }

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final gameDetails = widget.game;
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/background.jpg'), fit: BoxFit.cover),
        ),
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              //here
              TourAppBar(game: gameDetails),

              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              gameDetails != null
                                  ? gameDetails.gameName
                                  : 'Null',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.gamepad_outlined,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        gameDetails != null
                                            ? gameDetails.genre.join(', ')
                                            : 'Null',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                          gameDetails != null
                                              ? gameDetails.developer
                                              : 'Null',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.date_range_outlined,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        gameDetails != null
                                            ? gameDetails.releaseDate
                                            : 'Null',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        child: TabBar(
                          controller: _tabController,
                          indicatorPadding: EdgeInsets.zero,
                          labelPadding: const EdgeInsets.all(1),
                          indicatorSize: TabBarIndicatorSize.label,

                          indicatorColor: const Color(0xff1DA1F2),
                          indicatorWeight: 1,
                          dividerColor: Colors.transparent,
                          labelStyle: Theme.of(context).textTheme.titleSmall,
                          unselectedLabelStyle:
                              Theme.of(context).textTheme.bodySmall,
                          tabs: const [
                            Text('Overview'),
                            Text('Tournaments'),
                          ],
                          labelColor: Colors
                              .white, // Change the color to blue for the selected tab label
                          unselectedLabelColor: const Color(0xff72767A),
                        ),
                      ), // Abdullah
                      // use ur phone in teams as a new device
                    ),
                  ],
                ),
              ),
            ];
          },
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: TabBarView(
              controller: _tabController,
              children: [
                // first tab bar view widget
                Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'About the Game',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(color: Color.fromARGB(82, 219, 219, 219)),
                      const SizedBox(height: 10),
                      Text(
                        gameDetails != null ? gameDetails.description : 'Null',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                // second tab bar view widget
                Container(
                  height:
                      187.0, // Set the height to match the height of the TournamentInfoCard
                  child: 
                    RelatedTournaments(gameDetails.gameName),
                ),
                // third tab bar view widget
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TourAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final Game game;
  const TourAppBar({super.key, required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameDetails = game;
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.12,
      // the property below can be refactored to handle profile view
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const <StretchMode>[
          StretchMode.zoomBackground,
          StretchMode.blurBackground
        ],
        background: Container(
          height: MediaQuery.of(context).size.height * 0.18,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                gameDetails.bannerPicture,
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      iconTheme: const IconThemeData(size: 20.0),
      leading: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: Colors.black.withOpacity(0.6)),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}


class RelatedTournaments extends ConsumerStatefulWidget {
  final String gameName;
  const RelatedTournaments(this.gameName, {Key? key}) : super(key: key);

  @override
  _RelatedTournamentsState createState() => _RelatedTournamentsState();
}

class _RelatedTournamentsState extends ConsumerState<RelatedTournaments> {
  @override
  void initState() {
    super.initState();
    Future(() {
      ref.read(tournamentListStateProvider.notifier).getTournamentsGameName(widget.gameName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(tournamentListStateProvider).when(
          data: (RelatedTournaments) {
            if (RelatedTournaments.isEmpty) {
              return const Center(
                child: Text('There are no tournaments currently available for this game.'),
              );
            } 
            else {
              return RefreshIndicator(
                onRefresh: () async {
                  ref
                      .read(tournamentListStateProvider.notifier)
                      .getTournamentsGameName(widget.gameName);
                },
                child: ListView(
                  padding: const EdgeInsets.only(top: 10),
                  children: [
                    ...RelatedTournaments.map((tournament) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TournamentManagementView(
                                      tournamentId: tournament.id,
                                    )),
                          );
                        },
                        child: TournamentCard(
                            tournamentImage: tournament.thumbnail,
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
