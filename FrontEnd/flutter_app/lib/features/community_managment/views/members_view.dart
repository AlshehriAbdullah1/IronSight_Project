import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/Common%20Widgets/MainPage.dart';
import 'package:iron_sight/Common%20Widgets/smallFollowButton.dart';
import 'package:iron_sight/features/community_managment/controller/community_provider.dart';
import 'package:iron_sight/features/community_managment/controller/member_provider.dart';
import 'package:iron_sight/features/user_managment/controller/auth_provider.dart';
import 'package:iron_sight/features/user_managment/controller/user_provider.dart';
import 'package:iron_sight/features/user_managment/views/profile_page_view.dart';
import 'package:iron_sight/features/user_managment/widgets/followList.dart';
import 'package:iron_sight/Common%20Widgets/popUpScreen.dart';

// need user service
// final ownerProvider = StateProvider<bool>((ref) => true);
// final adminProvider = StateProvider<bool>((ref) => false);
// final moderatorProvider = StateProvider<bool>((ref) => false);

class MembersView extends ConsumerStatefulWidget {
  const MembersView({super.key});

  @override
  ConsumerState<MembersView> createState() => _MembersViewState();
}

class _MembersViewState extends ConsumerState<MembersView>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ref.read(membersStateProvider.notifier).getMembers();
  }

  int _currentIndex = 3;
  @override
  Widget build(BuildContext context) {
    // final CommunityDetails = ref.watch(userStateProvider);
    final membersAsync = ref.watch(membersStateProvider);
    final userId = ref.read(authControllerProvider.notifier).getCurrentUserId();
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
                leading: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.6)),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ),
            ];
          },
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/background.jpg'),
                  fit: BoxFit.cover),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
              child: membersAsync.when(
                data: (data) {
                  //  print('inserting member to the ui${data[0].displayName}');
                  final isOwner = ref.read(singleCommunityStateProvider.notifier).isOwner();
                  final isModerator = ref.read(singleCommunityStateProvider.notifier).isModerator();
                  final isMember = ref.read(singleCommunityStateProvider.notifier).isMember();
                  
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.read(membersStateProvider.notifier).getMoreMembers();
                    },
                    triggerMode: RefreshIndicatorTriggerMode.onEdge,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 15),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final member = data[index];
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                //Check if the user is the owner or a moderator
                                // if so, show the popup menu
                                // don't show the popup menu for the user himself
                               if ((isOwner || (isModerator && member.id != data[0].id))
                               && member.id != userId)
                                  
                                  PopupMenuButton<String>(
                                    color: const Color.fromRGBO(91, 41, 143, 1),
                                    onSelected: (value) {},
                                    itemBuilder: (BuildContext context) {
                                      List<PopupMenuItem<String>> items = [];

                                      items.addAll([
                                        PopupMenuItem<String>(
                                          value: 'mod/unmod',
                                          child: Text(
                                            'Set / Unset as moderator',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                          onTap: () async {
                                            if (member.isModerator) {
                                              showPopUp(context,
                                                  'Are you sure you want to remove moderation?',
                                                  () async {
                                                await ref
                                                    .read(membersStateProvider
                                                        .notifier)
                                                    .removeModerator(
                                                        member.id, context);
                                                await ref
                                                    .read(membersStateProvider
                                                        .notifier)
                                                    .getMembers();
                                              });
                                            } else {
                                              showPopUp(context,
                                                  'Are you sure you want to set this member as moderator?',
                                                  () async {
                                                await ref
                                                    .read(membersStateProvider
                                                        .notifier)
                                                    .setModerator(
                                                        member.id, context);
                                                await ref
                                                    .read(membersStateProvider
                                                        .notifier)
                                                    .getMembers();
                                              });
                                            }
                                          },
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'remove from community',
                                          child: Text(
                                            'Remove from community',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                          onTap: () {
                                            showPopUp(context,
                                                "Are you sure you want to remove this member",
                                                () async {
                                              bool response = await ref
                                                  .read(membersStateProvider
                                                      .notifier)
                                                  .removeMember(
                                                      member.id, context);
                                              if (response) {
                                                ref
                                                    .read(
                                                        singleCommunityStateProvider
                                                            .notifier)
                                                    .reduceMembersCount();
                                              }
                                            });
                                          },
                                        ),
                                        PopupMenuItem(
                                          value: 'blocked',
                                          child: Text(
                                            'Block from community',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                          onTap: () {
                                            showPopUp(context,
                                                "Are you sure you want to block this member",
                                                () async {
                                              bool response = await ref
                                                  .read(
                                                      blockedMembersStateProvider
                                                          .notifier)
                                                  .blockMember(
                                                      member.id, context);
                                              await ref.read(membersStateProvider.notifier).getMembers();
                                              if (response) {
                                                ref
                                                    .read(
                                                        singleCommunityStateProvider
                                                            .notifier)
                                                    .reduceMembersCount();
                                              }
                                            });
                                          },
                                        )
                                      ]);

                                      return items;
                                    },
                                  ),
                                InkWell(
                                  onTap: () {
                                    // load the user first
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) => ProfileView()));
                                  },
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(member.userImage),
                                          radius: 25,
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            member.displayName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                          ),
                                          Text(
                                            member.userName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          if (member.isOwner)
                                            const Text('• Owner',
                                                style: TextStyle(
                                                    fontSize: 13.0,
                                                    color: Colors.yellow,
                                                    fontFamily: "Inter")),
                                          if (member.isModerator)
                                            const Text('• Moderator',
                                                style: TextStyle(
                                                    fontSize: 13.0,
                                                    color: Colors.cyan,
                                                    fontFamily: "Inter")),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (member.id != userId)
                              smallFollowButton(onClicked: () {}),
                          ],
                        );
                      },
                    ),
                  );
                  // return followList( membersList: data.members);
                },
                error: (error, stackTrace) {
                  return Center(
                      child: Text("error in getting memeber data : $error"));
                },
                loading: () {
                  return const Center(child: CustomProgressIndicator());
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
