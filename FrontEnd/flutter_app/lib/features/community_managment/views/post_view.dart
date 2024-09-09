import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/Common%20Widgets/reportForm.dart';
import 'package:iron_sight/features/community_managment/controller/community_provider.dart';
import 'package:iron_sight/features/community_managment/controller/post_provider.dart';
import 'package:iron_sight/features/community_managment/widgets/community_image_viewer.dart';
import 'package:iron_sight/Common%20Widgets/TournamentInfoCard.dart';
import 'package:iron_sight/Common%20Widgets/smallFollowButton.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/Common%20Widgets/myAppBar.dart';
import 'package:iron_sight/features/community_managment/widgets/post_reply_textField.dart';
import 'package:iron_sight/features/community_managment/widgets/replyCard.dart';
import 'package:iron_sight/features/community_managment/widgets/postActionRow.dart';
import 'package:iron_sight/features/community_managment/widgets/postCard.dart';
import 'package:iron_sight/models/post.dart';
import 'package:iron_sight/models/user.dart';

final ownerProvider = StateProvider<bool>((ref) => false);
String dropdownValue = 'New';

class PostView extends ConsumerStatefulWidget {
  Post post;
  List<String>? postImages;
  PostView({
    super.key,
    required this.post,
    this.postImages,
  });

  @override
  ConsumerState<PostView> createState() => _PostViewState();
}

class _PostViewState extends ConsumerState<PostView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _replyController = TextEditingController();
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
    ref.read(communityRepliesProvider.notifier).loadReplies(widget.post.id);
  }

  int _currentIndex = 3; //For the bottom navigation bar

  @override
  Widget build(BuildContext context) {
    final isOwner = ref.read(singleCommunityStateProvider.notifier).isOwner();
    final replyAsync = ref.watch(communityRepliesProvider);

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children:  <Widget> [Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      AppBar(
                        backgroundColor: Colors.transparent,
                        leading: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.6)),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          /////////////////////Main post/////////////////////
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: CircleAvatar(
                                            backgroundImage:
                                                NetworkImage(widget.post.poster.profilePicture),
                                            radius: 25,
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(widget.post.poster.displayName,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge),
                                            Text(widget.post.poster.userName,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium),
                                          ],
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        // smallFollowButton(onClicked: () {}),
                                        PopupMenuButton<String>(
                                          iconSize: 18,
                                          color: const Color.fromRGBO(
                                              91, 41, 143, 1),
                                          onSelected: (value) {},
                                          itemBuilder: (BuildContext context) {
                                            List<PopupMenuItem<String>> items = [
                                              // PopupMenuItem<String>(
                                              //   value: 'Follow',
                                              //   child: Text(
                                              //     'Follow ${widget.post.poster.userName}',
                                              //     style: Theme.of(context)
                                              //         .textTheme
                                              //         .titleSmall,
                                              //   )
                                              // ),
                                            ];
        
                                            if (!isOwner) {
                                              items.addAll([
                                                PopupMenuItem<String>(
                                                  value: 'report',
                                                  child: Text(
                                                    'Report',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleSmall,
                                                  ),
                                                  onTap: () {
                                                    reportFormPopUp(context);
                                                  },
                                                ),
                                              ]);
                                            }
                                            if (isOwner) {
                                              items.addAll([
                                                PopupMenuItem<String>(
                                                  value: 'delete',
                                                  child: Text(
                                                    'Delete',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleSmall,
                                                  ),
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ]);
                                            }
        
                                            return items;
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(
                                  widget.post.postContent,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(height: 5),
                                if (widget.postImages != null &&
                                    widget.postImages!.isNotEmpty)
                                  if (widget.postImages!.length == 3)
                                    Column(
                                      children: [
                                        InkWell(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            child: Image.network(
                                                widget.postImages![0],
                                                fit: BoxFit.cover),
                                          ),
                                          onTap: () {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (context) => ImageViewer(
                                                image: widget.postImages![0],
                                                post: widget.post,
                                              ),
                                            ));
                                          },
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: InkWell(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    child: Image.network(
                                                        widget.postImages![1],
                                                        fit: BoxFit.cover),
                                                  ),
                                                ),
                                                onTap: () {
                                                  Navigator.of(context)
                                                      .push(MaterialPageRoute(
                                                    builder: (context) =>
                                                        ImageViewer(
                                                      image:
                                                          widget.postImages![1],
                                                      post: widget.post,
                                                    ),
                                                  ));
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Expanded(
                                              child: InkWell(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    child: Image.network(
                                                        widget.postImages![2],
                                                        fit: BoxFit.cover),
                                                  ),
                                                ),
                                                onTap: () {
                                                  Navigator.of(context)
                                                      .push(MaterialPageRoute(
                                                    builder: (context) =>
                                                        ImageViewer(
                                                      image:
                                                          widget.postImages![2],
                                                      post: widget.post,
                                                    ),
                                                  ));
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  else
                                    GridView.count(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      crossAxisCount:
                                          widget.postImages!.length > 1 ? 2 : 1,
                                      mainAxisSpacing: 5,
                                      crossAxisSpacing: 5,
                                      children: widget.postImages!.map((image) {
                                        return InkWell(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              image: DecorationImage(
                                                image: NetworkImage(image),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          onTap: () {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (context) => ImageViewer(
                                                image: image,
                                                post: widget.post,
                                              ),
                                            ));
                                          },
                                        );
                                      }).toList(),
                                    ),
                                const SizedBox(height: 5),
                                Text("${widget.post.getHumaneDate()}",
                                    style:
                                        Theme.of(context).textTheme.labelMedium),
                                const SizedBox(height: 5),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Divider(
                                color: Colors.white.withOpacity(0.2),
                                height: 1,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 20),
                                child: postActionRow(
                                  postId: widget.post.id,
                                  commentCount: widget.post.posterReplyCount,
                                  likeCount: widget.post.postLikeCount,
                                  userId: widget.post.poster.userId,
                                ),
                              ),
                              Divider(
                                color: Colors.white.withOpacity(0.2),
                                height: 1,
                              ),
                              Divider(
                                color: Colors.white.withOpacity(0.2),
                                height: 1,
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ];
            },
            body: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: replyAsync.when(data: (data) {
                  if (data == null || data == []) {
                    return Center(
                      child: Text(
                        "No posts found, data is empty",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  } else {
                    return RefreshIndicator(
                      onRefresh: () async {
                        // ref
                        //     .read(communityRepliesProvider(widget.post.id))
                        //     .(widget.post.id);
                      },
                      triggerMode: RefreshIndicatorTriggerMode.onEdge,
                      // child: Text("tesint"),
                      child: ListView.builder(
                        physics: ScrollPhysics(),
                        padding: const EdgeInsets.only(top: 15),
                        itemCount: data.length,
                        // shrinkWrap: true,
                        // physics: ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final reply = data[index];
                          // return PostCard(
                          //   post: reply,
                          //   postImages: reply.postImages,
                          // );
                          return ReplyCard(
                              reply: reply);
                        },
                      ),
                    );
                  }
                }, error: (error, stacktrace) {
                  return Center(
                    child: Text('Error $error, stacktrace : $stacktrace'),
                  );
                }, loading: () {
                  return const Center(
                    child: CustomProgressIndicator(),
                  );
                })),
          ),
        ),
        Positioned(
        bottom: MediaQuery.of(context).viewInsets.bottom, // Dynamically adjust the bottom position
        left: 0,
        right: 0,
        child: PostReplyTextField(widget.post),
      ),
      ],),
    );
  }
}
