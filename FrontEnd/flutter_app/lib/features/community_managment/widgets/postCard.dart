import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/Common%20Widgets/reportForm.dart';
import 'package:iron_sight/features/community_managment/controller/community_provider.dart';
import 'package:iron_sight/features/community_managment/controller/post_provider.dart';
import 'package:iron_sight/features/community_managment/widgets/community_image_viewer.dart';
import 'package:iron_sight/features/community_managment/views/community_page_view.dart';
import 'package:iron_sight/features/community_managment/views/post_view.dart';
import 'package:iron_sight/features/community_managment/widgets/postActionRow.dart';
import 'package:iron_sight/features/user_managment/controller/user_provider.dart';
import 'package:iron_sight/models/post.dart';

class PostCard extends ConsumerStatefulWidget {
  Post post;
  // String postTime;
  PostCard({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  final TextEditingController _replyController = TextEditingController();
    final pendingProvider = StateProvider<bool>((ref) => false);


  @override
  Widget build(BuildContext context) {
     bool isOwner = ref.read(singleCommunityStateProvider.notifier).isOwner();
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PostView(
            postImages: widget.post.postMedia,
            post: widget.post,
          ),
        ));
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(widget.post.poster.displayName,
                                style: Theme.of(context).textTheme.bodyLarge),
                            Text(widget.post.poster.userName,
                                style: Theme.of(context).textTheme.labelMedium),
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text("${widget.post.getHumaneDate()}",
                            style: Theme.of(context).textTheme.labelMedium),
                        PopupMenuButton<String>(
                          iconSize: 18,
                          color: const Color.fromRGBO(91, 41, 143, 1),
                          onSelected: (value) {},
                          itemBuilder: (BuildContext context) {
                            List<PopupMenuItem<String>> items = [
                              PopupMenuItem<String>(
                                value: 'Follow',
                                child: Text(
                                  'Follow ${widget.post.poster.userName}',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                            ];

                            if (isOwner) {
                              items.addAll([
                                PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text(
                                    'Delete',
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  onTap: () {
                                    String? communityId = ref
                                        .read(singleCommunityStateProvider.notifier).getCurrentCommunityId();
                                    
                                    if(communityId != null){
                                      ref
                                        .read(communityPostsProvider.notifier)
                                        .removePost(
                                            communityId, widget.post.id);
                                    }
                                    else{
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Error: Community ID is null"),
                                        ),
                                      );

                                    }
                                    
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
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 5),
                if (widget.post.postMedia != null &&
                    widget.post.postMedia!.isNotEmpty)
                  if (widget.post.postMedia!.length == 3)
                    Column(
                      children: [
                        InkWell(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(widget.post.postMedia![0],
                                fit: BoxFit.cover),
                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ImageViewer(
                                  post: widget.post,
                                  image: widget.post.postMedia![0]),
                            ));
                          },
                        ),
                        const SizedBox(height: 5),
                        Container(
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.network(
                                          widget.post.postMedia![1],
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => ImageViewer(
                                        image: widget.post.postMedia![1],
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
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.network(
                                          widget.post.postMedia![2],
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => ImageViewer(
                                        image: widget.post.postMedia![2],
                                        post: widget.post,
                                      ),
                                    ));
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: widget.post.postMedia!.length > 1 ? 2 : 1,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                      children: widget.post.postMedia!.map((image) {
                        return InkWell(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              image: DecorationImage(
                                image: NetworkImage(image),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ImageViewer(
                                image: image,
                                post: widget.post,
                              ),
                            ));
                          },
                        );
                      }).toList(),
                    ),
                
                
                postActionRow(
                  postId: widget.post.id,
                  commentCount: widget.post.posterReplyCount,
                  likeCount: widget.post.postLikeCount,
                  userId: widget.post.poster.userId,
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.white.withOpacity(0.2),
            height: 1,
          ),
          const SizedBox(height: 15),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
