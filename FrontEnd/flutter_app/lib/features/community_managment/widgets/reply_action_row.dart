import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/features/community_managment/controller/post_provider.dart';
import 'package:iron_sight/models/reply.dart';

class ReplyActionRow extends ConsumerStatefulWidget {
  final Reply reply;
  const ReplyActionRow({required this.reply});

  @override
  _ReplyActionRowState createState() => _ReplyActionRowState();
}

class _ReplyActionRowState extends ConsumerState<ReplyActionRow> {
  final buttonIconProvider =
      StateProvider<Icon>((ref) => const Icon(Icons.favorite_border, size: 22));
  final likedChecker = StateProvider<bool>((ref) => false);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                child: ref.watch(buttonIconProvider),
                onTap: () {
                  try {
                    if (ref.read(likedChecker.notifier).state == false) {
                    ref.read(communityRepliesProvider.notifier).likeReply(
                        widget.reply.id, widget.reply.associatedWithPost);
                    ref.read(likedChecker.notifier).state = true;
                    ref.read(buttonIconProvider.notifier).state = const Icon(
                        Icons.favorite,
                        size: 22,
                        color: Color.fromRGBO(136, 69, 205, 1));
                  } else {
                    ref.read(communityRepliesProvider.notifier).likeReply(
                        widget.reply.id, widget.reply.associatedWithPost);
                    ref.read(buttonIconProvider.notifier).state =
                        const Icon(Icons.favorite_border, size: 22);
                    ref.read(likedChecker.notifier).state = false;
                  }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                  
                },
              ),
              const SizedBox(width: 5),
              Text('${widget.reply.replyLikeCount}',
                  style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
          // InkWell(
          //   child: Row(
          //     children: [
          //       const Icon(Icons.share, size: 18),
          //       const SizedBox(width: 5),
          //       Text("Share", style: Theme.of(context).textTheme.labelMedium),
          //     ],
          //   ),
          //   onTap: () {
          //   },
          // ),
        ],
      ),
    );
  }
}
