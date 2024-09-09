import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/Common%20Widgets/MainPage.dart';
import 'package:iron_sight/Common%20Widgets/reportForm.dart';
import 'package:iron_sight/features/tournament_managment/controller/tournament_provider.dart';
import 'package:iron_sight/features/tournament_managment/views/tournament_creation_view.dart';
import 'package:iron_sight/features/tournament_managment/views/tournament_edit_view.dart';
import 'package:iron_sight/features/tournament_managment/widgets/ResultsTab.dart';
import 'package:iron_sight/features/tournament_managment/widgets/details_tab.dart';
import 'package:iron_sight/Common%20Widgets/popUpScreen.dart';
import 'package:iron_sight/Common%20Widgets/smallFollowButton.dart';
// import 'package:iron_sight/features/tournament_managment/widgets/highlights.dart';
import 'package:iron_sight/features/tournament_managment/widgets/matches_tab.dart';
import 'package:iron_sight/features/tournament_managment/widgets/comment_tab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/features/user_managment/controller/user_provider.dart';

final adminProvider = StateProvider<bool>((ref) => true);
final inHouseProvider = StateProvider<bool>((ref) => true);

class TournamentManagementView extends ConsumerStatefulWidget {
  final String tournamentId;

   TournamentManagementView({super.key,required this.tournamentId});

  @override
  ConsumerState<TournamentManagementView> createState() =>
      _TournamentManagementViewState();
}

class _TournamentManagementViewState
    extends ConsumerState<TournamentManagementView>
    with SingleTickerProviderStateMixin {
  late bool inHouse;
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
    inHouse = ref.read(inHouseProvider.notifier).state;
    _tabController = TabController(length: inHouse ? 4 : 3, vsync: this);
    Future(() async{
      await ref
        .read(singleTournamentStateProvider.notifier)
        .getTournament(widget.tournamentId);
        ref.read(userProvider.notifier).loadIsFollowingTournament(widget.tournamentId);
    } );
    
  }


  @override
  Widget build(BuildContext context) {
    final tournamentDetails = ref.watch(singleTournamentStateProvider);
    final userState = ref.watch(userProvider);
   final isFollowingTournament =ref.read(userProvider.notifier).isFollowingTournament(widget.tournamentId);
    //  final isFollowingTournament =false;

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
              tournamentDetails.when(data: (data) {
                return  TourAppBar(bannerImage: data.banner,);
              }, error: (error, stackTrace) {
                return SliverToBoxAdapter(child: Center(child: Text('$error'),));
              }, loading: () {
                return  SliverToBoxAdapter(child: Center(child: CustomProgressIndicator(),));
              },),
             
             
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                     tournamentDetails.when(data: (data) {
        
                    return  Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                          
                                   data.tournamentName
                                  ,
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
                                        Icons.date_range,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        '${data.date} at ${data.time}'
                                             ,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 2,
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
                                           data.tournamentGame
                                              ,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.business,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        data.tournamentOrg
                                        
                                           ,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                         '${data.location}' 
                                               ,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              
                              smallFollowButton(onClicked: () async{
                                if(isFollowingTournament){
                                  try {
                                      await ref.read(singleTournamentStateProvider.notifier).unFollowTournament();

                                  } catch (e) {
                                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text(
                                        e.toString(),
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ));
                                  }
                                }
                                else{
                                  try {
                                    await ref.read(singleTournamentStateProvider.notifier).followTournament();
                                  } catch (e,stackTrace) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text(
                                        e.toString(),
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ));
                                  }
                                  
                                }
                             
                              },isFollowing: isFollowingTournament,),
                            ],
                          ),
                        ],
                      ),
                    );
                
              }, error: (error, stackTrace) {
                
                  return  Center(child: Text('${error}'),);
        
        
              }, loading: () {
                return const Center(child: CustomProgressIndicator(),);
              },),
                    
                    Padding(
                      padding: const EdgeInsets.all(12.0),
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
                        tabs: [
                          const Text('Details'),
                          if (inHouse) const Text('Matches'),
                          const Text('Results'),
                          const Text('Comments'),
                          // const Text('Highlights'),
                        ],
                        labelColor: Colors
                            .white, // Change the color to blue for the selected tab label
                        unselectedLabelColor: const Color(0xff72767A),
                         ),
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
             tournamentDetails.when(
                data: (data) {
                  return details_tab(participants: data.participants??[],
                  date: data.date,
                  isStarted: data.isStarted,
                  description: data.description,
                  prizePool: data.prizePool,
                  streamingLink: data.streamingLink,
                  maxParticipants: data.maxParticipants,
                  result: data.results,
                  
                  
                  );
                },
                error: (error, stackTrace) {
                  return Center(child: Text('$error'));
                },
                loading: () {
                  return const Center(child: CustomProgressIndicator());
                },
              ),
              if (inHouse) const MatchesTab(),
              const ResultsTab(),
              CommentsTab(),
              // Container(
              //   color: Colors.pink,
              //   child: const Center(
              //     // child: Text(
              //     //   'Highlights here ',
              //     // ),
              //   ),
              // ),
              // VideoThumbnailGrid()
              ],
            ),
          ),
        ),
      ),
   
    );
  }
}

class TourAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String bannerImage;
  const TourAppBar({super.key,required this.bannerImage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOrganizer = ref.watch(singleTournamentStateProvider.notifier).isOwner();
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
          decoration:  BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                
               bannerImage,
              ),
              fit: BoxFit.fill,
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
      // actions: [
      //   Padding(
      //     padding: const EdgeInsets.only(right: 10.0),
      //     child: Container(
      //       width: 45,
      //       height: 45,
      //       decoration: BoxDecoration(
      //           shape: BoxShape.circle, color: Colors.black.withOpacity(0.6)),
      //       child: PopupMenuButton<String>(
      //         color: const Color.fromRGBO(91, 41, 143, 1),
      //         onSelected: (value) {},
      //         itemBuilder: (BuildContext context) {
      //           List<PopupMenuItem<String>> items = [
      //             // PopupMenuItem<String>(
      //             //   value: 'share',
      //             //   child: Text(
      //             //     'Share',
      //             //     style: Theme.of(context).textTheme.titleSmall,
      //             //   ),
      //             // ),
      //             if(!isOrganizer)
                  
                  
      //             PopupMenuItem<String>(
      //               value: 'report',
      //               child: Text(
      //                 'Report',
      //                 style: Theme.of(context).textTheme.titleSmall,
      //               ),
      //               onTap: () {
      //                 reportFormPopUp(context);
      //               },
      //             ),
      //           ];

      //           if (isOrganizer) {
      //             // Use the context.read method from the provider package
      //             // Add additional menu items for admin
      //             items.addAll([
      //               // PopupMenuItem<String>(
      //               //   value: 'edit',
      //               //   child: Text(
      //               //     'Edit',
      //               //     style: Theme.of(context).textTheme.titleSmall,
      //               //   ),
      //               //   onTap: () {
      //               //     Navigator.push(
      //               //       context,
      //               //       MaterialPageRoute(
      //               //         builder: (context) =>
      //               //             const TournamentCreationView(),
      //               //       ),
      //               //     );
      //               //   },
      //               // ),
      //               // PopupMenuItem<String>(
      //               //   value: 'delete',
      //               //   child: Text(
      //               //     'Delete',
      //               //     style: Theme.of(context).textTheme.titleSmall,
      //               //   ),
      //               //   onTap: () {
      //               //     showPopUp(context,
      //               //         "Are you sure you want to delete this tournament",
      //               //         () {
      //               //       // ref
      //               //       //     .read(singleTournamentStateProvider.notifier)
      //               //       //     .deleteTournament("M1Gk2z1glM2F0yFaeBdD");
      //               //     });
      //               //   },
      //               // ),
      //             ]);
      //           }

      //           return items;
      //         },
      //       ),
      //     ),
      //   ),
      // ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
