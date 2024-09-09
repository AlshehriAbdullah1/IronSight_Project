import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/Common%20Widgets/MainPage.dart';
import 'package:iron_sight/features/community_managment/controller/community_provider.dart';
import 'package:iron_sight/features/community_managment/controller/member_provider.dart';
import 'package:iron_sight/features/community_managment/widgets/blockButton.dart';
import 'package:iron_sight/features/user_managment/controller/user_provider.dart';
import 'package:iron_sight/features/user_managment/views/profile_page_view.dart';

class BlockedMembersView extends ConsumerStatefulWidget {
  const BlockedMembersView({super.key});

  @override
  ConsumerState<BlockedMembersView> createState() => _BlockedMembersViewState();
}

class _BlockedMembersViewState extends ConsumerState<BlockedMembersView>
    with SingleTickerProviderStateMixin {
  Future? _loadBlockedMembersFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadBlockedMembersFuture =
        ref.read(blockedMembersStateProvider.notifier).loadBlockedMembers();
  }

  int _currentIndex = 3;
  @override
  Widget build(BuildContext context) {
    final blockedMembersAsync = ref.watch(blockedMembersStateProvider);
    final communitystate = ref.watch(singleCommunityStateProvider);
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
              child: FutureBuilder(
                future: _loadBlockedMembersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CustomProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Center(
                            child: Text(
                                "error in getting member data : ${snapshot.error}")));
                  } else {
                    return RefreshIndicator(
                      onRefresh: () async {
                        ref
                            .read(blockedMembersStateProvider.notifier)
                            .loadBlockedMembers();
                      },
                      triggerMode: RefreshIndicatorTriggerMode.onEdge,
                      child: blockedMembersAsync.when(
                        data: (data) {
                          if (data == [] || data.isEmpty) {
                            return const Center(
                                child: Text("No Blocked members"));
                          }
                          // ...
                          //  print('inserting member to the ui${data[0].displayName}');
                          return ListView.builder(
                            padding: const EdgeInsets.only(top: 15),
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              final member = data[index];
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(),
                                      InkWell(
                                        onTap: () {
                                          // load the user first
                                          // Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //         builder: (context) => ProfileView(
                                          //             userId: member.id)));
                                        },
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    member.userImage),
                                                radius: 25,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
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
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  BlockButton(
                                    memberId: member.id,
                                    community_id: communitystate.value!.id,
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        error: (error, stackTrace) {
                          return Center(
                              child: Text(
                                  "error in getting member data : $error"));
                        },
                        loading: () {
                          return const Center(child: CustomProgressIndicator());
                        },
                      ),
                    );
                  }
                },
                // child: blockedMembersAsync.when(
                //   data: (data) {

                //     // return followList( membersList: data.members);
                //   },
                //   error: (error, stackTrace) {
                //     return Center(
                //         child: Text("error in getting memeber data : $error"));
                //   },
                //   loading: () {
                //     return const Center(child: CircularProgressIndicator());
                //   },
                // ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
