import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/features/community_managment/controller/post_provider.dart';

//User service is required for this widget to work
class postActionRow extends ConsumerStatefulWidget {
  final String postId;
  final int likeCount;
  final int commentCount;
  final String userId;

  postActionRow(
      {required this.postId,
      required this.likeCount,
      required this.commentCount,
     
      required this.userId});

  @override
  _postActionRowState createState() => _postActionRowState();
}

class _postActionRowState extends ConsumerState<postActionRow> {
  final buttonIconProvider =
      StateProvider<Icon>((ref) => const Icon(Icons.favorite_border, size: 22));
  final likedChecker = StateProvider<bool>((ref) => false);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            child: Row(
              children: [
                ref.watch(buttonIconProvider),
                const SizedBox(width: 5),
                Text("${widget.likeCount}",
                    style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
            onTap: () {
              if (ref.read(likedChecker.notifier).state == false) {
                ref
                    .read(communityPostsProvider.notifier)
                    .likePost(widget.postId, widget.userId);
                ref.read(likedChecker.notifier).state = true;
                ref.read(buttonIconProvider.notifier).state = const Icon(
                    Icons.favorite,
                    size: 22,
                    color: Color.fromRGBO(136, 69, 205, 1));
              } else {
                ref
                    .read(communityPostsProvider.notifier)
                    .unLikePost(widget.postId, widget.userId);
                ref.read(buttonIconProvider.notifier).state =
                    const Icon(Icons.favorite_border, size: 22);
                ref.read(likedChecker.notifier).state = false;
              }
            },
          ),
          InkWell(
            child: Row(
              children: [
                const Icon(Icons.comment_outlined, size: 22),
                const SizedBox(width: 5),
                Text("${widget.commentCount}",
                    style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
            onTap: () {
            },
          ),
          // InkWell(
          //   child: Row(
          //     children: [
          //       const Icon(Icons.share, size: 22),
          //       const SizedBox(width: 5),
          //       Text("Share", style: Theme.of(context).textTheme.labelMedium),
          //     ],
          //   ),
          //   onTap: () {
          //     print("Share");
          //   },
          // ),
        ],
      ),
    );
  }
}
