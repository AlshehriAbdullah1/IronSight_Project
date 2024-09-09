import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class createPostActionRow extends ConsumerStatefulWidget {
  final String postId;

  createPostActionRow({required this.postId});

  @override
  _createPostActionRowState createState() => _createPostActionRowState();
}

class _createPostActionRowState extends ConsumerState<createPostActionRow> {
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
                Text("19k",
                    style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
            onTap: () {
              if (ref.read(likedChecker.notifier).state == false) {
                ref.read(likedChecker.notifier).state = true;
                ref.read(buttonIconProvider.notifier).state = const Icon(
                    Icons.favorite,
                    size: 22,
                    color: Color.fromRGBO(136, 69, 205, 1));
              } else {
                ref.read(buttonIconProvider.notifier).state =
                    const Icon(Icons.favorite_border, size: 22);
                ref.read(likedChecker.notifier).state = false;
              }
              ;
            },
          ),
          InkWell(
            child: Row(
              children: [
                const Icon(Icons.comment_outlined, size: 22),
                const SizedBox(width: 5),
                Text("5k",
                    style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
            onTap: () {
              // print("Comment");
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
