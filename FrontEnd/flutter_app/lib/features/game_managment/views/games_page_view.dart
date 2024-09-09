import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/Common%20Widgets/GameCard.dart';
import 'package:iron_sight/Common%20Widgets/drawer.dart';
import 'package:iron_sight/features/game_managment/controller/game_provider.dart';
import 'package:iron_sight/features/game_managment/views/game_page_view.dart';
import 'package:iron_sight/features/user_managment/controller/user_provider.dart';

class GameView extends ConsumerStatefulWidget {
  const GameView({super.key});

  @override
  ConsumerState<GameView> createState() => _GameViewState();
}

class _GameViewState extends ConsumerState<GameView>
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
    Future(() {
      ref.read(userProvider.notifier).loadUserGames();
    });
  }

  int _currentIndex = 2; //For the bottom navigation bar

  @override
  Widget build(BuildContext context) {
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
              SliverAppBar(
                backgroundColor: Colors.transparent,
                title: Text(
                  "Games",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                centerTitle: true, // This centers the title
                leading: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: InkWell(
                    onTap: () {
                      Scaffold.of(context)
                          .openDrawer(); // This opens the drawer
                    },
                    child: const Icon(
                      Icons
                          .menu, // This changes the icon to a menu (hamburger) icon
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Column(
                      children: [
                        //       Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: TextField(
                        //     decoration: InputDecoration(
                        //       hintText: 'Search',
                        //       hintStyle: TextStyle(color: Color(0xFF707070)),
                        //       prefixIcon: Icon(Icons.search),
                        //       suffixIcon: Icon(Icons.filter_list),
                        //       filled: true,
                        //       fillColor: Color(0xFF242424),
                        //       border: OutlineInputBorder(
                        //         borderRadius: BorderRadius.all(Radius.circular(30.0)),
                        //         borderSide: BorderSide.none,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 12, 0, 5),
                          child: TabBar(
                            controller: _tabController,
                            indicatorPadding: EdgeInsets.zero,
                            indicatorSize: TabBarIndicatorSize.label,
                            indicatorColor: const Color(0xff1DA1F2),
                            indicatorWeight: 1,
                            dividerColor: Colors.transparent,
                            labelStyle: Theme.of(context).textTheme.titleSmall,
                            unselectedLabelStyle:
                                Theme.of(context).textTheme.bodySmall,
                            tabs: const [
                              Text('Followed'),
                              Text('Discover'),
                            ],
                            labelColor: Colors
                                .white, // Change the color to blue for the selected tab label
                            unselectedLabelColor: const Color(0xff72767A),
                          ), // Abdullah
                          // use ur phone in teams as a new device
                        ),
                      ],
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
              children: const [
                // Here we shall add the list of communities that the user follows
                // HomeGames(),
                HomeGames(),
                // Here we shall add the list of communities that the user does not follow
                DiscoverGames(),
              ],
            ),
          ),
        ),
      ),
      drawer: const TopLeftDrawer(),
    );
  }
}

class DiscoverGames extends ConsumerStatefulWidget {
  const DiscoverGames({Key? key}) : super(key: key);

  @override
  _DiscoverGamesState createState() => _DiscoverGamesState();
}

class _DiscoverGamesState extends ConsumerState<DiscoverGames> {
  @override
  void initState() {
    super.initState();
    Future(() {
      ref.read(gameListStateProvider.notifier).loadGames();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user= ref.read(userProvider);
    return ref.watch(gameListStateProvider).when(
          data: (discoverGames) {
            if (discoverGames.isEmpty) {
              return const Center(
                child: Text('No games to display'),
              );
            } else {
              return ListView(
                padding: const EdgeInsets.only(top: 10),
                children: [
                  ...discoverGames.map((game) {
                                        bool isFollowing = ref.read(userProvider.notifier).isFollowingGame(game); 

                    return InkWell(
                      onTap: () {
                        ref
                            .read(singleGameStateProvider.notifier)
                            .getGame(game.id)
                            .then((value) => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => GamePageView(
                                            game: game,
                                          )),
                                ));
                      },
                      child: GameCard(
                        gameId: game.id,
                        gameName: game.gameName,
                        gameDecsription: game.description,
                        gameimage: game.mainPicture,
                      ),
                    );
                  })
                ],
              );
            }
          },
          loading: () => const Center(child: CustomProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        );
  }
}

class HomeGames extends ConsumerStatefulWidget {
  const HomeGames({Key? key}) : super(key: key);

  @override
  _HomeGamesState createState() => _HomeGamesState();
}

class _HomeGamesState extends ConsumerState<HomeGames> {
  @override
  void initState() {
    super.initState();
    Future(() {
      ref.read(gameListStateProvider.notifier).loadGames(isHomeView: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    return ref.watch(userGamesProvider).when(
          data: (homeGames) {
            if (homeGames.isEmpty) {
              return const Center(
                child: Text('No games to display'),
              );
            } else {
              return ListView(
                padding: const EdgeInsets.only(top: 10),
                children: [
                  ...homeGames.map((game) {
                    return InkWell(
                      onTap: () {
                        ref
                            .read(singleGameStateProvider.notifier)
                            .getGame(game.id)
                            .then((value) => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => GamePageView(
                                            game: game,
                                          )),
                                ));
                      },
                      child: GameCard(
                        gameId: game.id,
                        gameName: game.gameName,
                        gameDecsription: game.description,
                        gameimage: game.mainPicture,
                      ),
                    );
                  })
                ],
              );
            }
          },
          loading: () => const Center(child: CustomProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        );
  }
}
