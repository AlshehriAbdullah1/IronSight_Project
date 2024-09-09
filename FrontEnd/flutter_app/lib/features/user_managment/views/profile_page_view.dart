import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iron_sight/APIs/auth_api_client.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/Common%20Widgets/TournamentInfoCard.dart';
import 'package:iron_sight/Common%20Widgets/smallFollowButton.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/features/tournament_managment/controller/tournament_provider.dart';
import 'package:iron_sight/features/tournament_managment/views/tournament_management_view.dart';
import 'package:iron_sight/features/user_managment/controller/auth_provider.dart';
import 'package:iron_sight/features/user_managment/controller/user_provider.dart';
import 'package:iron_sight/features/user_managment/views/following_page_view.dart';
import 'package:iron_sight/features/user_managment/views/profile_edit_view.dart';
import 'package:iron_sight/Common%20Widgets/myAppBar.dart';
import 'package:iron_sight/models/tournament.dart';
import 'package:iron_sight/models/user.dart';
import '../../../Common Widgets/MainPage.dart';
import 'followers_page_view.dart';

final ownerProvider = StateProvider<bool>((ref) => true);

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    // ref.read(userProvider.notifier).loadUser(ref.read(authControllerProvider.notifier).);
  }


  

  int _currentIndex = 3; //For the bottom navigation bar

  @override
  Widget build(BuildContext context) {
    final userDetails = ref.watch(userProvider);

    final isOwner = ref.read(userProvider.notifier).isOwner;
    return PopScope(
      canPop: Navigator.of(context).canPop(),
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: userDetails.isLoading
            ? const Center(
                child: CustomProgressIndicator(),
              )
            : userDetails.error != null
                ? Center(child: Text(userDetails.error!))
                : Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/background.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: NestedScrollView(
                      headerSliverBuilder: (context, innerBoxIsScrolled) {
                        return <Widget>[
                          //here
                          myAppBar(
                            isVerified: userDetails.user?.isVerified??false,
                            isOwner: isOwner,
                            profileImage: (userDetails.user != null &&
                                    userDetails.user?.profilepic != '' &&
                                    userDetails.user != null)
                                ? userDetails.user!.profilepic
                                : "https://storage.googleapis.com/download/storage/v1/b/iron-sight/o/Games%2F0MWzjERANTDyjAlVBlDE%2FGame_Img_Banner.png?generation=1713761047624832&alt=media",
                            bannerImage: (userDetails != null &&
                                    userDetails.user?.banner != '' &&
                                    userDetails.user != null)
                                ? userDetails.user!.banner
                                : "https://storage.googleapis.com/download/storage/v1/b/iron-sight/o/Games%2F0MWzjERANTDyjAlVBlDE%2FGame_Img_Banner.png?generation=1713761047624832&alt=media",
                            editFunction: () {
                              isOwner
                                  ? Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                      return ProfileEditView();
                                    }))
                                  : ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Your are not the the owner of this profile'),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                            },
                            shareFunction: () {},
                          ),
                          SliverList(
                            delegate: SliverChildListDelegate(
                              [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 5),
                                                  child: Text(
                                                    (userDetails != null &&
                                                            userDetails.user !=
                                                                null)
                                                        ? userDetails
                                                            .user!.displayName
                                                        : 'Loading...',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleLarge,
                                                  ),
                                                ),
                                                Text(
                                                  (userDetails != null &&
                                                          userDetails.user !=
                                                              null)
                                                      ? userDetails
                                                          .user!.username
                                                      : 'Loading...',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium,
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    ElevatedButton(
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all(Colors
                                                                    .transparent),
                                                        elevation:
                                                            MaterialStateProperty
                                                                .all(0),
                                                        padding:
                                                            MaterialStateProperty
                                                                .all(EdgeInsets
                                                                    .zero),
                                                        minimumSize:
                                                            MaterialStateProperty
                                                                .all(Size.zero),
                                                        overlayColor:
                                                            MaterialStateProperty
                                                                .all(Colors
                                                                    .transparent),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              'Following: ',
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .titleSmall,
                                                            ),
                                                            Text(
                                                              (userDetails !=
                                                                          null &&
                                                                      userDetails
                                                                              .user !=
                                                                          null)
                                                                  ? userDetails
                                                                      .user!
                                                                      .Following
                                                                      .length
                                                                      .toString()
                                                                  : 'Loading...',
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .labelMedium,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        //for future work
                                                        // Navigator.push(
                                                        //   context,
                                                        //   MaterialPageRoute(
                                                        //       builder: (context) =>
                                                        //           const FollowingView()),
                                                        // );
                                                      },
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    ElevatedButton(
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all(Colors
                                                                    .transparent),
                                                        elevation:
                                                            MaterialStateProperty
                                                                .all(0),
                                                        padding:
                                                            MaterialStateProperty
                                                                .all(EdgeInsets
                                                                    .zero),
                                                        minimumSize:
                                                            MaterialStateProperty
                                                                .all(Size.zero),
                                                        overlayColor:
                                                            MaterialStateProperty
                                                                .all(Colors
                                                                    .transparent),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(0),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              'Followers: ',
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .titleSmall,
                                                            ),
                                                            Text(
                                                              (userDetails !=
                                                                          null &&
                                                                      userDetails
                                                                              .user !=
                                                                          null)
                                                                  ? userDetails
                                                                      .user!
                                                                      .Followers
                                                                      .length
                                                                      .toString()
                                                                  : 'Loading...',
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .labelMedium,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        // future work
                                                        // Navigator.push(
                                                        //   context,
                                                        //   MaterialPageRoute(
                                                        //       builder: (context) =>
                                                        //           const FollowersView()),
                                                        // );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  (userDetails != null &&
                                                          userDetails.user !=
                                                              null)
                                                      ? userDetails.user!.bio
                                                      : 'Loading...',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
                                                )
                                              ],
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              if (!isOwner)
                                                Column(
                                                  children: [
                                                    smallFollowButton(
                                                      onClicked: () {},
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                  ],
                                                ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xff381A57)
                                                      .withOpacity(0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        'Badges:',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleSmall,
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Column(
                                                        children: [
                                                          Icon(
                                                            FontAwesomeIcons
                                                                .medal,
                                                            color: Colors
                                                                .yellow[700],
                                                          ),
                                                          const SizedBox(
                                                              height: 5),
                                                          Text(userDetails
                                                                      .user !=
                                                                  null
                                                              ? (userDetails
                                                                          .user!
                                                                          .Badges['First_Place'] ??
                                                                      0)
                                                                  .toString()
                                                              : '0'),
                                                          Icon(
                                                            FontAwesomeIcons
                                                                .medal,
                                                            color: Colors
                                                                .grey[400],
                                                          ),
                                                          const SizedBox(
                                                              height: 5),
                                                          Text(userDetails
                                                                      .user !=
                                                                  null
                                                              ? (userDetails
                                                                          .user!
                                                                          .Badges['Second_Place'] ??
                                                                      0)
                                                                  .toString()
                                                              : '0'),
                                                          const SizedBox(
                                                              height: 5),
                                                          Icon(
                                                            FontAwesomeIcons
                                                                .medal,
                                                            color: Colors
                                                                .brown[500],
                                                          ),
                                                          const SizedBox(
                                                              height: 5),
                                                          Text(userDetails
                                                                      .user !=
                                                                  null
                                                              ? (userDetails
                                                                          .user!
                                                                          .Badges['Third_Place'] ??
                                                                      0)
                                                                  .toString()
                                                              : '0'),
                                                          const SizedBox(
                                                              height: 5)
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text("Tournaments",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 12, 0, 5),
                                      child: TabBar(
                                        tabAlignment: TabAlignment.start,
                                        isScrollable: true,
                                        controller: _tabController,
                                        indicatorPadding: EdgeInsets.zero,
                                        labelPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 25),
                                        indicatorSize:
                                            TabBarIndicatorSize.label,
                                        indicatorColor: const Color(0xff1DA1F2),
                                        indicatorWeight: 1,
                                        dividerColor: Colors.transparent,
                                        labelStyle: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                        unselectedLabelStyle: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                           
                                        tabs: const [
                                          Text('Followed'),
                                          Text('Current'),
                                          Text('Upcoming'),
                                          Text('Previous'),
                                          Text('Organized'),
                                        ],
                                        labelColor: Colors
                                            .white, // Change the color to blue for the selected tab label
                                        unselectedLabelColor:
                                            const Color(0xff72767A),
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
                          children:const [
                            // Followed Tournaments
                            FollowedTournaments(),
                            // Current Tournaments
                           CurrentTournaments(),
                            // Upcoming tournaments
                           UpcomingTournaments(),

                            // Previous Tournaments
                           PreviousTournaments(),
                            // Organized Tournaments
                            OrganizedTournaments(),
                          
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}

class OrganizedTournaments extends ConsumerWidget {
  const OrganizedTournaments({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentState = ref.watch(getParticpatedTournaments('Organized'));

    return tournamentState.when(
      data: (data) {
         if(data!.isEmpty ){
          return Center(child: Text('You have no organized tournaments',style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium,),);
        }
        return ListView(
          children: data!.map((item) {
            
            return InkWell(
              onTap: () async{
                

               NavigatorState CNTXT = Navigator.of(context);
                CNTXT.pop();
                CNTXT.push(MaterialPageRoute(builder: (context) {
                  return TournamentManagementView(tournamentId: item.id,);
                },));
              },
              child: TournamentInfoCard(
                tournamentId: item.id,
                tournamenName: item.tournamentName,
                tournamentDate: item.date,
                tournamentGame: item.tournamentGame,
                tournamentType: item.type,
                tournamentOrg: item.tournamentOrg,
                tournamentimage: item.thumbnail,
              ),
            );
          }).toList(),
        );
      },
      error: (error, stackTrace) {
        return Center(
          child: Text(stackTrace.toString()),
        );
      },
      loading: () {
        return const Center(
          child: CustomProgressIndicator(),
        );
      },
    );
  }
}

class FollowedTournaments extends ConsumerWidget {
  const FollowedTournaments({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentState = ref.watch(getParticpatedTournaments('Followed'));

    return tournamentState.when(
      data: (data) {
        if(data!.isEmpty ){
          return Center(child: Text('You have no followed tournaments',style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium,),);
        }
        return ListView(
          children: data!.map((item) {
            return InkWell(
              onTap: () async{
              
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return  TournamentManagementView(tournamentId: item.id,);
                },));
              },
            child: TournamentInfoCard(
              tournamentId: item.id,
              tournamenName: item.tournamentName,
              tournamentDate: item.date,
              tournamentGame: item.tournamentGame,
              tournamentType: item.type,
              tournamentOrg: item.tournamentOrg,
              tournamentimage: item.thumbnail,
            ),
          );
          }).toList(),
        );
      },
      error: (error, stackTrace) {
        return Center(
          child: Text(stackTrace.toString()),
        );
      },
      loading: () {
        return const Center(
          child: CustomProgressIndicator(),
        );
      },
    );
  }
}

class UpcomingTournaments extends ConsumerWidget {
  const UpcomingTournaments({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentState = ref.watch(getParticpatedTournaments('Upcoming'));

    return tournamentState.when(
      data: (data) {
           if(data!.isEmpty ){
          return Center(child: Text('You have no upcoming tournaments',style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium,),);
        }
        return ListView(
          children: data!.map((item) {
         
          
            return InkWell(
              onTap: () {
            
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return  TournamentManagementView(tournamentId: item.id,);
                },));
              },
              child: TournamentInfoCard(
                tournamentId: item.id,
                tournamenName: item.tournamentName,
                tournamentDate: item.date,
                tournamentGame: item.tournamentGame,
                tournamentType: item.type,
                tournamentOrg: item.tournamentOrg,
                tournamentimage: item.thumbnail,
              ),
            );
          }).toList(),
        );
      },
      error: (error, stackTrace) {
        return Center(
          child: Text(stackTrace.toString()),
        );
      },
      loading: () {
        return const Center(
          child: CustomProgressIndicator(),
        );
      },
    );
  }
}

class PreviousTournaments extends ConsumerWidget {
  const PreviousTournaments({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentState = ref.watch(getParticpatedTournaments('Previous'));

    return tournamentState.when(
      data: (data) {
          if(data!.isEmpty ){
          return Center(child: Text('You have no previous tournaments',style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium,),);
        }
        return ListView(
          children: data!.map((item) {
           
            return InkWell(
              onTap: () {
               
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return  TournamentManagementView(tournamentId: item.id,);
                },));
              },
              child: TournamentInfoCard(
                tournamentId: item.id,
                tournamenName: item.tournamentName,
                tournamentDate: item.date,
                tournamentGame: item.tournamentGame,
                tournamentType: item.type,
                tournamentOrg: item.tournamentOrg,
                tournamentimage: item.thumbnail,
              ),
            );
          }).toList(),
        );
      },
      error: (error, stackTrace) {
        return Center(
          child: Text(stackTrace.toString()),
        );
      },
      loading: () {
        return const Center(
          child: CustomProgressIndicator(),
        );
      },
    );
  }
}

class CurrentTournaments extends ConsumerWidget {
  const CurrentTournaments({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentState = ref.watch(getParticpatedTournaments('Current'));

    return tournamentState.when(
      data: (data) {
             if(data!.isEmpty ){
          return Center(child: Text('You have no current tournaments',style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium,),);
        }
        return ListView(
          children: data!.map((item) {
         
            return InkWell(
              onTap: () {
             
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return  TournamentManagementView(tournamentId: item.id,);
                },));
              },
              child: TournamentInfoCard(
                tournamentId: item.id,
                tournamenName: item.tournamentName,
                tournamentDate: item.date,
                tournamentGame: item.tournamentGame,
                tournamentType: item.type,
                tournamentOrg: item.tournamentOrg,
                tournamentimage: item.thumbnail,
              ),
            );
          }).toList(),
        );
      },
      error: (error, stackTrace) {
        return Center(
          child: Text(stackTrace.toString()),
        );
      },
      loading: () {
        return const Center(
          child: CustomProgressIndicator(),
        );
      },
    );
  }
}