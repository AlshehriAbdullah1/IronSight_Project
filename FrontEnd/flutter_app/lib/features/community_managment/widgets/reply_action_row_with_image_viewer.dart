import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/models/reply.dart';

class ReplyActionRowWithImageViewer extends ConsumerStatefulWidget {
  final Reply reply;
  final String image;
  const ReplyActionRowWithImageViewer({required this.reply,required this.image});

  @override
  _ReplyActionRowWithImageViewerState createState() => _ReplyActionRowWithImageViewerState();
}

class _ReplyActionRowWithImageViewerState extends ConsumerState<ReplyActionRowWithImageViewer> {
  final buttonIconProvider =
      StateProvider<Icon>((ref) => const Icon(Icons.favorite_border, size: 22));
  final likedChecker = StateProvider<bool>((ref) => false);

  @override
  Widget build(BuildContext context) {
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
          child: Image.network(widget.image),
        ),),
        bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        elevation: 0,
        child: 
           
             Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            child: Row(
              children: [
                ref.watch(buttonIconProvider),
                const SizedBox(width: 5),
                Text("${widget.reply.replyLikeCount}", style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
            onTap: () {
              if (ref.read(likedChecker.notifier).state == false) {
                ref.read(likedChecker.notifier).state = true;
                ref.read(buttonIconProvider.notifier).state = const Icon(
                    Icons.favorite,
                    size: 18,
                    color: Color.fromRGBO(136, 69, 205, 1));
              } else {
                ref.read(buttonIconProvider.notifier).state =
                    const Icon(Icons.favorite_border, size: 18);
                ref.read(likedChecker.notifier).state = false;
              }
              ;
            },
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
          //     print("Share");
          //   },
          // ),
        ],
      ),
    ),
      ),
        
        
    );
    
  }
}

