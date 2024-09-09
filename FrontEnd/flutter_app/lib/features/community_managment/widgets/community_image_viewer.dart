import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/features/community_managment/widgets/postActionRow.dart';
import 'package:iron_sight/features/community_managment/widgets/reply_action_row_with_image_viewer.dart';
import 'package:iron_sight/features/community_managment/widgets/reply_action_row_with_image_viewer.dart';
import 'package:iron_sight/models/post.dart';
import 'package:iron_sight/models/reply.dart';

class ImageViewer extends ConsumerWidget {
  // final String image;
  final Post? post;
  final String image;
  ImageViewer({super.key, this.post, required this.image});
  final buttonIconProvider =
      StateProvider<Icon>((ref) => const Icon(Icons.favorite_border, size: 18));
  final likedChecker = StateProvider<bool>((ref) => false);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
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
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(image),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        elevation: 0,
        child: 
             postActionRow(
                postId: post!.id,
                commentCount: post!.posterReplyCount,
                likeCount: post!.postLikeCount,
                userId: post!.poster.userId,
            )
         
      ),
    );
  }
}
