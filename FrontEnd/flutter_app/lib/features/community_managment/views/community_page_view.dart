import 'package:flutter/material.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/Common%20Widgets/smallFollowButton.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/Common%20Widgets/myAppBar.dart';
import 'package:iron_sight/features/community_managment/controller/member_provider.dart';
import 'package:iron_sight/features/community_managment/controller/post_provider.dart';
import 'package:iron_sight/features/community_managment/views/community_edit_view.dart';
import 'package:iron_sight/features/community_managment/views/members_view.dart';
import 'package:iron_sight/features/community_managment/widgets/community_follow_btn.dart';
import 'package:iron_sight/features/community_managment/widgets/postCard.dart';
import 'package:iron_sight/features/community_managment/widgets/postCreation.dart';
import 'package:iron_sight/models/community.dart';
import '../../../Common Widgets/MainPage.dart';
import 'package:iron_sight/features/community_managment/controller/community_provider.dart';

// final ownerProvider = StateProvider<bool>((ref) => true);

// List<String> ListOfImages0 = [];
// List<String> ListOfImages1 = [
//   'https://img.redbull.com/images/c_limit,w_1500,h_1000,f_auto,q_auto/redbullcom/2023/11/10/k1n2y7tfjjavx4sqwg7u/street-fighter-6'
// ];
// List<String> ListOfImages2 = [
//   'https://img.redbull.com/images/c_limit,w_1500,h_1000,f_auto,q_auto/redbullcom/2023/11/10/k1n2y7tfjjavx4sqwg7u/street-fighter-6',
//   'https://images.gamebanana.com/img/ss/mods/621ef628b0aa6.jpg'
// ];
// List<String> ListOfImages3 = [
//   'https://img.redbull.com/images/c_limit,w_1500,h_1000,f_auto,q_auto/redbullcom/2023/11/10/k1n2y7tfjjavx4sqwg7u/street-fighter-6',
//   'https://images.gamebanana.com/img/ss/mods/621ef628b0aa6.jpg',
//   'https://cdn.akamai.steamstatic.com/steam/apps/1364780/extras/13_Custom-Images_ST.png?t=1709012771',
// ];
// List<String> ListOfImages4 = [
//   'https://img.redbull.com/images/c_limit,w_1500,h_1000,f_auto,q_auto/redbullcom/2023/11/10/k1n2y7tfjjavx4sqwg7u/street-fighter-6',
//   'https://images.gamebanana.com/img/ss/mods/621ef628b0aa6.jpg',
//   'https://cdn.akamai.steamstatic.com/steam/apps/1364780/extras/13_Custom-Images_ST.png?t=1709012771',
//   'https://cdn.mos.cms.futurecdn.net/Ax62rUQ4WAotXNTF5Whpfg-1200-80.jpg',
// ];

class CommunityView extends ConsumerStatefulWidget {
  final String communityId;

  const CommunityView({super.key, required this.communityId});

  @override
  ConsumerState<CommunityView> createState() => _CommunityViewState();
}

class _CommunityViewState extends ConsumerState<CommunityView>
    with SingleTickerProviderStateMixin {
  String dropdownValue = 'New';
  late TabController _tabController;
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
    // ref.watch(communityPostsProvider.notifier).dispose();
    // ref.watch(communityStateProvider.notifier).dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    Future(() {
          ref.read(communityPostsProvider.notifier).getPosts(widget.communityId);

    },);
  }

  // Future<void> loadPosts(String communityId){
  //   ref.read(communityPostsProvider.notifier).getPosts(communityId);
  // }
  int _currentIndex = 3; //For the bottom navigation bar

  @override
  Widget build(BuildContext context) {
    final isFollowing =
        ref.watch(singleCommunityStateProvider.notifier).isMember();
    final isModerator =
        ref.watch(singleCommunityStateProvider.notifier).isModerator();
    final isOwner = ref.watch(singleCommunityStateProvider.notifier).isOwner();
    final communityAsync = ref.watch(singleCommunityStateProvider);
    final postAsync = ref.watch(communityPostsProvider);
    // Here we will get the posts data from the API
    // final postsAsync = ref.watch(postsStateProvider);
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          (isFollowing || isModerator ||isOwner) ?
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return const FractionallySizedBox(
                heightFactor:
                    0.9, // This makes the widget take up 70% of the screen height
                child:  CreatePost(),
                alignment: Alignment.bottomCenter,
              );
            },
          ): ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be a follower of this community to post.'),
        ),
      ); ;
        },
        shape: const CircleBorder(),
        backgroundColor: const Color.fromRGBO(136, 69, 205, 1),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .miniEndFloat, // This aligns the button to the right
      body: communityAsync.when(
        loading: () {
          return const Center(child: CustomProgressIndicator());
        },
        error: (error, stackTrace) {
          return Center(
            child: Text('$error'),
          );
        },
        data: (data) {
          // FutureBuilder(() {

          // },);
          // loadPosts(data.id);
          return Container(
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
                      isVerified: data.isVerified,
                      isOwner: isOwner,
                      profileImage: data.communityPicture,
                      bannerImage: data.banner,
                      appBarType: "Community",
                      editFunction: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return CommunityEditView(
                              communityId: widget.communityId);
                        }));
                      },
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: Text(
                                              //Community Name
                                              data.communityName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                          ),
                                          Text(
                                            //#Hashtag
                                            data.communityTag,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              // ref.read(membersStateProvider.notifier).getMembers();

                                              Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                builder: (context) {
                                                  return const MembersView();
                                                },
                                              ));
                                            },
                                            child: Text(
                                              //Member + moderators + owner count
                                              "${data.membersLength + data.moderatorsLength + 1} Members",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium!
                                                  .copyWith(
                                                    color: const Color.fromRGBO(
                                                        186, 144, 255, 1.000),
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            //Community Description
                                            data.description,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                          DropdownButton<String>(
                                            dropdownColor: const Color.fromRGBO(
                                                91, 41, 143, 1),
                                            value: dropdownValue,
                                            underline: Container(),
                                            iconSize: 18,
                                            icon: const Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.white,
                                            ),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                dropdownValue = newValue!;
                                              });
                                              if (dropdownValue == 'Popular') {
                                                ref
                                                    .read(communityPostsProvider
                                                        .notifier)
                                                    .getMostPopularPosts(
                                                        widget.communityId);
                                              } else if (dropdownValue ==
                                                  'New') {
                                                ref
                                                    .read(communityPostsProvider
                                                        .notifier)
                                                    .getPosts(
                                                        widget.communityId);
                                              }
                                            },
                                            items: <String>['New', 'Popular']
                                                .map<DropdownMenuItem<String>>(
                                                    (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Row(
                                                  children: <Widget>[
                                                    Icon(
                                                      value == 'New'
                                                          ? Icons
                                                              .new_releases_rounded
                                                          : Icons
                                                              .local_fire_department_rounded,
                                                      size: 18,
                                                    ),
                                                    const SizedBox(
                                                        width:
                                                            5), // Add some space between the icon and the text
                                                    Text(value),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // if (!isFollowing &&
                                        //     !isModerator &&
                                        //     !isOwner)
                                        //   Column(
                                        //     children: [
                                        //       smallFollowButton(
                                        //         isFollowing: isFollowing,
                                        //         onClicked: () async {
                                        //           // follow the community button
                                        //           try {
                                        //             await ref
                                        //                 .read(
                                        //                     communityStateProvider
                                        //                         .notifier)
                                        //                 .followCommunity();
                                        //           } catch (e) {
                                        //             // Scaffold messanger

                                        //             ScaffoldMessenger.of(
                                        //                     context)
                                        //                 .showSnackBar(SnackBar(
                                        //               content: Text(
                                        //                 e.toString(),
                                        //                 style: Theme.of(context)
                                        //                     .textTheme
                                        //                     .bodyMedium,
                                        //               ),
                                        //             ));
                                        //           }
                                        //         },
                                        //       ),
                                        //       const SizedBox(
                                        //         height: 10,
                                        //       ),
                                        //     ],
                                        //   ),
                                        if (!isModerator && !isOwner)
                                          CommunityFollowButton(communityId: data.id,),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.white.withOpacity(0.2),
                            height: 1,
                          ),
                        ],
                      ),
                    ),
                  ];
                },
                body: postAsync.when(
                  loading: () {
                    return const Center(
                      child: CustomProgressIndicator(),
                    );
                  },
                  data: (data) {
                    if (data.isEmpty || data == []) {
                      print('data is empty');

                      return Center(
                        child: Text(
                          "No posts found",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    } else {
                      return RefreshIndicator(
                        onRefresh: () async {
                          ref
                              .read(communityPostsProvider.notifier)
                              .getPosts(widget.communityId);
                        },
                        triggerMode: RefreshIndicatorTriggerMode.onEdge,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 15),
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final post = data[index];
                            return PostCard(
                              post: post,
                            );
                          },
                        ),
                      );
                    }
                  },
                  error: (error, stackTrace) {
                    return Center(
                      child: Text('Error $error, stacktrace : $stackTrace'),
                    );
                  },
                )),
          );
        },
      ),
    );
  }
}
