import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/Common%20Widgets/GameCard.dart';
import 'package:iron_sight/Common%20Widgets/TournamentInfoCard.dart';
import 'package:iron_sight/Common%20Widgets/drawer.dart';
import 'package:iron_sight/Common%20Widgets/communityCard.dart';
import 'package:iron_sight/features/community_managment/controller/community_provider.dart';
import 'package:iron_sight/features/community_managment/views/community_page_view.dart';
import 'package:iron_sight/features/search_managment/widgets/filterPopUp.dart';
import 'package:iron_sight/Common%20Widgets/AccountList.dart';
import '../../../Common Widgets/MainPage.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView>
    with SingleTickerProviderStateMixin {
  @override
  void dispose() {
    _tabController.dispose();
    _searchQuery.dispose();
    super.dispose();
  }

  final TextEditingController _searchQuery = TextEditingController();
  late TabController _tabController;
  // late String _searchQuery;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
                  "Search",
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
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _searchQuery,
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle:
                                  const TextStyle(color: Color(0xFF707070)),
                              prefixIcon: IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () {
                                  return FilterPopUp(context);
                                },
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.filter_list),
                                onPressed: () {
                                  return FilterPopUp(context);
                                },
                              ),
                              filled: true,
                              fillColor: const Color(0xFF242424),
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30.0)),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        // Tab bar
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 12, 0, 5),
                          child: TabBar(
                            tabAlignment: TabAlignment.start,
                            isScrollable: true,
                            controller: _tabController,
                            indicatorPadding: EdgeInsets.zero,
                            labelPadding:
                                const EdgeInsets.symmetric(horizontal: 25),
                            indicatorSize: TabBarIndicatorSize.label,
                            indicatorColor: const Color(0xff1DA1F2),
                            indicatorWeight: 1,
                            dividerColor: Colors.transparent,
                            labelStyle: Theme.of(context).textTheme.titleSmall,
                            unselectedLabelStyle:
                                Theme.of(context).textTheme.bodySmall,
                            tabs: const [
                              Text('Tournaments'),
                              Text('Games'),
                              Text('Accounts'),
                              Text('Communities'),
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
              children: [
                ListView(
                  padding: const EdgeInsets.only(top: 10),
                  children: [
                    for (var i = 0; i < 5; i++)
                      TournamentInfoCard(
                          tournamenName: _searchQuery.text.isEmpty
                              ? "Street Fighter 6"
                              : _searchQuery.text,
                          tournamentDate: "12/12/2021",
                          tournamentGame: "Street Fighter 6",
                          tournamentId: "",
                          tournamentOrg: "@SFL",
                          tournamentType: "Online",
                          tournamentimage:
                              "https://cdn.cloudflare.steamstatic.com/steam/apps/1364780/library_600x900_2x.jpg?t=1707964327"),
                  ],
                  
                ),
                ListView(
                  padding: const EdgeInsets.only(top: 10),
                  // children: [
                  //   for (var i = 0; i < 5; i++)
                      // GameCard(
                      //   gameId: widget.gameId,
                      //   gameName: _searchQuery.text.isEmpty
                      //         ? "Street Fighter 6"
                      //         : _searchQuery.text,
                      //   gameDecsription:
                      //       "Street Fighter 6 is a 2023 fighting game developed and published by Capcom. It marks the seventh main entry in the Street Fighter franchise. The game was announced in February 2022 and released on June 2, 2023, for PlayStation 4, PlayStation 5, Windows, and Xbox Series X/S. An arcade version titled Street Fighter 6 Type Arcade, developed by Taito, hit Japanese arcade cabinets on December 14, 2023. Additionally, a prequel comic book series was unveiled in September 2022.",
                      //   gameimage:
                      //       "https://cdn.cloudflare.steamstatic.com/steam/apps/1364780/library_600x900_2x.jpg?t=1707964327",
                      // ),
                  // ],
                ),
                const AccountList(
                  avatar: AssetImage('assets/avatar.jpg'),
                  accounts: [
                    {'Display_Name': 'User 1', 'User_Name': "User_1"},
                    {'Display_Name': 'User 2', 'User_Name': "User_2"},
                    {'Display_Name': 'User 3', 'User_Name': "User_3"},
                  ],
                ),
                ListView(
                  padding: const EdgeInsets.only(top: 10),
                  children: [
                    // for (var i = 0; i < 5; i++)
                    //   CommunityCard(
                    //       communityImage:
                    //           "https://cdn.cloudflare.steamstatic.com/steam/apps/1364780/library_600x900_2x.jpg?t=1707964327",
                    //       communityName: "Street fighter 6",
                    //       communityDescription:
                    //           "Home of Street Fighter 6 on IronSight, a place where you can drive rush cancel into tournaments and engage in amazing matches with other players."
                    //           ),
                  ],
                ),
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
