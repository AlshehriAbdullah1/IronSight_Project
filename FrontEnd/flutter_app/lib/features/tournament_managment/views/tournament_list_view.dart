import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/Common%20Widgets/MainPage.dart';
import 'package:iron_sight/Common%20Widgets/drawer.dart';
import 'package:iron_sight/features/tournament_managment/controller/tournament_provider.dart';
import 'package:iron_sight/features/tournament_managment/views/tournament_management_view.dart';
import 'package:iron_sight/features/tournament_managment/widgets/tournament_card.dart';
import 'package:iron_sight/models/tournament.dart';

class TournamentListView extends ConsumerStatefulWidget {
  const TournamentListView({super.key});

  @override
  ConsumerState<TournamentListView> createState() => _TournamentListViewState();
}

class _TournamentListViewState extends ConsumerState<TournamentListView>
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
  }

  int _currentIndex = 1;
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
                  "Tournaments",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                centerTitle: true,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: InkWell(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: const Icon(
                      Icons.menu,
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
                        // Search bar
                        // const Padding(
                        //   padding: EdgeInsets.all(8.0),
                        //   child: TextField(
                        //     decoration: InputDecoration(
                        //       hintText: 'Home',
                        //       hintStyle: TextStyle(color: Color(0xFF707070)),
                        //       prefixIcon: Icon(Icons.search),
                        //       suffixIcon: Icon(Icons.filter_list),
                        //       filled: true,
                        //       fillColor: Color(0xFF242424),
                        //       border: OutlineInputBorder(
                        //         borderRadius:
                        //             BorderRadius.all(Radius.circular(30.0)),
                        //         borderSide: BorderSide.none,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // Tab bar
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
                              Text('For You'),
                              Text('Discover'),
                            ],
                            labelColor: Colors.white,
                            unselectedLabelColor: const Color(0xff72767A),
                          ),
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
                HomeTournaments(),
                // Here we shall add the list of communities that the user does not follow
                DiscoverTournaments(),
              ],
            ),
          ),
        ),
      ),

      /// bottom navigation bar
      drawer: const TopLeftDrawer(),
    );
  }
}

class DiscoverTournaments extends ConsumerStatefulWidget {
  const DiscoverTournaments({Key? key}) : super(key: key);

  @override
  _DiscoverTournamentsState createState() => _DiscoverTournamentsState();
}

class _DiscoverTournamentsState extends ConsumerState<DiscoverTournaments> {
  @override
  void initState() {
    super.initState();
    Future(() {
      ref.read(tournamentListStateProvider.notifier).loadTournaments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(tournamentListStateProvider).when(
          data: (discoverTournaments) {
            if (discoverTournaments.isEmpty) {
              return const Center(
                child: Text('No tournaments to display'),
              );
            } else {
              return ListView(
                padding: const EdgeInsets.only(top: 10),
                children: [
                  ...discoverTournaments.map((tournament) {
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
                        tournament: tournament,
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

class HomeTournaments extends ConsumerStatefulWidget {
  const HomeTournaments({Key? key}) : super(key: key);

  @override
  _HomeTournamentsState createState() => _HomeTournamentsState();
}

class _HomeTournamentsState extends ConsumerState<HomeTournaments> {
  @override
  void initState() {
    super.initState();
    Future(() {
      ref
          .read(tournamentListStateProvider.notifier)
          .loadTournaments(isHomeView: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(tournamentListStateProvider).when(
          data: (homeTournaments) {
            if (homeTournaments.isEmpty) {
              return const Center(
                child: Text('No tournaments to display'),
              );
            } else {
              return RefreshIndicator(
                onRefresh: () async {
                  ref
                      .read(tournamentListStateProvider.notifier)
                      .loadTournaments(isHomeView: true);
                },
                child: ListView(
                  padding: const EdgeInsets.only(top: 10),
                  children: [
                    ...homeTournaments.map((tournament) {
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
                          tournament: tournament,
                        ),
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
