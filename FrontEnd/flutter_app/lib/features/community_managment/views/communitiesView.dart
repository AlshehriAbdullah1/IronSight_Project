import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/Common%20Widgets/drawer.dart';
import 'package:iron_sight/Common%20Widgets/communityCard.dart';
import 'package:iron_sight/features/community_managment/controller/community_provider.dart';
import 'package:iron_sight/features/community_managment/views/community_page_view.dart';
import '../../../Common Widgets/MainPage.dart';

class CommunityListView extends ConsumerStatefulWidget {
  const CommunityListView({super.key});

  @override
  ConsumerState<CommunityListView> createState() => _CommunityListViewState();
}

class _CommunityListViewState extends ConsumerState<CommunityListView>
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
      
    });
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
                  "Communities",
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
                HomeCommunities(),
                // Here we shall add the list of communities that the user does not follow
                DiscoverCommunities(),
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

class DiscoverCommunities extends ConsumerStatefulWidget {
  const DiscoverCommunities({Key? key}) : super(key: key);

  @override
  _DiscoverCommunitiesState createState() => _DiscoverCommunitiesState();
}

class _DiscoverCommunitiesState extends ConsumerState<DiscoverCommunities> {
  @override
  void initState() {
    super.initState();
    Future(() {
      ref.read(communityListStateProvider.notifier).loadCommunities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(communityListStateProvider).when(
          data: (discoverCommunities) {
            if (discoverCommunities.isEmpty) {
              return const Center(
                child: Text('No communities to display'),
              );
            } 
            else {
              return ListView(
                padding: const EdgeInsets.only(top: 10),
                children: [
                  ...discoverCommunities.map((community) {
                    return InkWell(
                      onTap: () {
                        bool isOwnerOrModerator = ref.watch(communityListStateProvider.notifier).isOwnerOrModerator(community.id);
                          bool isMember = ref.watch(communityListStateProvider.notifier).isUserFollowing(community.id);
                          ref
                              .read(singleCommunityStateProvider.notifier)
                              .getCommunity(community.id)
                              .then((value) => 
                              
                              // Chcek if the community is password protected or the user is not a member
                              !isOwnerOrModerator&& 
                              !isMember
                              && community.password != null 
                              && community.password!.isNotEmpty
                                  ? showDialog(
                                      context: context,
                                      builder: (context) {
                                        String enteredPassword = '';
                                        return AlertDialog(
                                          title: const Center(
                                            child: Text(
                                              'Enter Password',
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          content: TextField(
                                            onChanged: (value) {
                                              enteredPassword = value;
                                            },
                                          ),
                                          backgroundColor: Color(0xff381A57).withOpacity(0.7),
                                          titleTextStyle: Theme.of(context).textTheme.titleMedium,

                                          actions: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              style: ButtonStyle(
                                                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                                  const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                                ),
                                                backgroundColor: MaterialStateProperty.all<Color>(
                                                  const Color.fromRGBO(136, 69, 205, 1),
                                                ),
                                                foregroundColor: MaterialStateProperty.all<Color>(
                                                  Colors.white,
                                                ),
                                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(15.0),
                                                  ),
                                                ),
                                              ),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                if (enteredPassword == community.password ) {
                                                  ref.read(singleCommunityStateProvider.notifier)
                                                    .getCommunity(community.id)
                                                    .then((value) {
                                                      Navigator.pop(context); // Pop the password prompt
                                                      // Push the community view
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => CommunityView(
                                                            communityId: community.id,
                                                          ),
                                                        ),
                                                      );
                                                    });
                                                }
                                                else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('Incorrect Password'),
                                                    ),
                                                  );
                                                  Navigator.pop(context);
                                                }
                                                
                                              },
                                              style: ButtonStyle(
                                                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                                  const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                                ),
                                                backgroundColor: MaterialStateProperty.all<Color>(
                                                  const Color.fromRGBO(136, 69, 205, 1),
                                                ),
                                                foregroundColor: MaterialStateProperty.all<Color>(
                                                  Colors.white,
                                                ),
                                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(15.0),
                                                  ),
                                                ),
                                              ),
                                              child: const Text('Submit'),
                                            ),
                                          ],
                                        );
                                      },
                                    )
                                  :
                              
                              Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CommunityView(
                                              communityId: community.id,
                                            )),
                                  ));
                      },
                      child: CommunityCard(
                          communityImage: community.communityPicture == ''
                              ? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRwrfuFM1mJ3C81T7HmBC-4grVn_2pHmo3anbYisceq7A&s'
                              : community.communityPicture,
                          communityName: community.communityName,
                          communityDescription: community.description,
                          communityId: community.id,
                          communityPassword: community.password,
                          communityIsVerfied: community.isVerified,
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

class HomeCommunities extends ConsumerStatefulWidget {
  const HomeCommunities({Key? key}) : super(key: key);

  @override
  _HomeCommunitiesState createState() => _HomeCommunitiesState();
}

class _HomeCommunitiesState extends ConsumerState<HomeCommunities> {
  @override
  void initState() {
    super.initState();
    Future(() {
      ref
          .read(communityListStateProvider.notifier)
          .loadCommunities(isHomeView: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(communityListStateProvider).when(
          data: (discoverCommunities) {
            if (discoverCommunities.isEmpty) {
              return const Center(
                child: Text('No communities to display'),
              );
            } else {
              return RefreshIndicator(
                onRefresh: () async {
                  ref
                      .read(communityListStateProvider.notifier)
                      .loadCommunities(isHomeView: true);
                },
                child: ListView(
                  padding: const EdgeInsets.only(top: 10),
                  children: [
                    ...discoverCommunities.map((community) {
                      return InkWell(
                        onTap: () {
                          bool isOwnerOrModerator = ref.watch(communityListStateProvider.notifier).isOwnerOrModerator(community.id);
                          bool isMember = ref.watch(communityListStateProvider.notifier).isUserFollowing(community.id);
                          ref
                              .read(singleCommunityStateProvider.notifier)
                              .getCommunity(community.id)
                              .then((value) => 
                              
                              // Chcek if the community is password protected or the user is not a member
                              !isOwnerOrModerator&& 
                              !isMember
                              && community.password != null 
                              && community.password!.isNotEmpty
                                  ? showDialog(
                                      context: context,
                                      builder: (context) {
                                        String enteredPassword = '';
                                        return AlertDialog(
                                          title: const Center(
                                            child: Text(
                                              'Enter Password',
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          content: TextField(
                                            onChanged: (value) {
                                              enteredPassword = value;
                                            },
                                          ),
                                          backgroundColor: Color(0xff381A57).withOpacity(0.7),
                                          titleTextStyle: Theme.of(context).textTheme.titleMedium,

                                          actions: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              style: ButtonStyle(
                                                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                                  const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                                ),
                                                backgroundColor: MaterialStateProperty.all<Color>(
                                                  const Color.fromRGBO(136, 69, 205, 1),
                                                ),
                                                foregroundColor: MaterialStateProperty.all<Color>(
                                                  Colors.white,
                                                ),
                                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(15.0),
                                                  ),
                                                ),
                                              ),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                if (enteredPassword == community.password ) {
                                                  ref.read(singleCommunityStateProvider.notifier)
                                                    .getCommunity(community.id)
                                                    .then((value) {
                                                      Navigator.pop(context); // Pop the password prompt
                                                      // Push the community view
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => CommunityView(
                                                            communityId: community.id,
                                                          ),
                                                        ),
                                                      );
                                                    });
                                                }
                                                else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('Incorrect Password'),
                                                    ),
                                                  );
                                                  Navigator.pop(context);
                                                }
                                                
                                              },
                                              style: ButtonStyle(
                                                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                                  const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                                ),
                                                backgroundColor: MaterialStateProperty.all<Color>(
                                                  const Color.fromRGBO(136, 69, 205, 1),
                                                ),
                                                foregroundColor: MaterialStateProperty.all<Color>(
                                                  Colors.white,
                                                ),
                                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(15.0),
                                                  ),
                                                ),
                                              ),
                                              child: const Text('Submit'),
                                            ),
                                          ],
                                        );
                                      },
                                    )
                                  :
                              
                              Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CommunityView(
                                              communityId: community.id,
                                            )),
                                  ));
                        },
                        child: CommunityCard(
                            communityImage: community.communityPicture == ''
                                ? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRwrfuFM1mJ3C81T7HmBC-4grVn_2pHmo3anbYisceq7A&s'
                                : community.communityPicture,
                            communityName: community.communityName,
                            communityDescription: community.description,
                            communityId: community.id,
                            communityPassword: community.password,
                            communityIsVerfied: community.isVerified,),
                      );
                    })
                  ],
                ),
              );
            }
          },
          loading: () => const Center(child: CustomProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        );
  }
}
