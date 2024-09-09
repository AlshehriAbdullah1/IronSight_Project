import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/Common%20Widgets/reportForm.dart';
import 'package:iron_sight/features/community_managment/widgets/community_image_viewer.dart';
import 'package:iron_sight/features/community_managment/widgets/reply_action_row.dart';
import 'package:iron_sight/features/community_managment/widgets/reply_action_row_with_image_viewer.dart';

import 'package:iron_sight/models/reply.dart';

class ReplyCard extends ConsumerStatefulWidget {
  final Reply reply;

  ReplyCard({Key? key, required this.reply}) : super(key: key);

  @override
  ConsumerState<ReplyCard> createState() => _ReplyCardState();
}

class _ReplyCardState extends ConsumerState<ReplyCard> {
  final buttonIconProvider =
      StateProvider<Icon>((ref) => const Icon(Icons.favorite_border, size: 18));
  final likedChecker = StateProvider<bool>((ref) => false);
  bool isOwner = false;

  @override
  Widget build(BuildContext context) {
    // return Text("reply card");
    return Column(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
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
                               NetworkImage(widget.reply.replier.profilePicture),
                              radius: 20,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(widget.reply.replier.displayName,
                                  style: Theme.of(context).textTheme.bodyLarge),
                              Text(widget.reply.replier.userName,
                                  style:
                                      Theme.of(context).textTheme.labelMedium),
                            ],
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Text("${widget.reply.getHumaneDate()}",
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
                                    'Follow ${widget.reply.replier.userName}',
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                ),
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
                                      // delete post
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
                    widget.reply.relpyContent,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.left,
                  ),
                  // const SizedBox(height: 5),
                  if (widget.reply.replyMedia != null &&
                      widget.reply.replyMedia!.isNotEmpty)
                    if (widget.reply.replyMedia!.length == 3)
                      Column(
                        children: [
                          InkWell(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(widget.reply.replyMedia[0],
                                  fit: BoxFit.cover),
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    ReplyActionRowWithImageViewer(
                                  image: widget.reply.replyMedia![0],
                                  reply: widget.reply,
                                ),
                              ));
                            },
                          ),
                          // const SizedBox(height: 5),
                          Container(
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: Image.network(
                                            widget.reply.replyMedia![1],
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) =>
                                            ReplyActionRowWithImageViewer(
                                          image: widget.reply.replyMedia![1],
                                          reply: widget.reply,
                                        ),
                                      ));
                                    },
                                  ),
                                ),
                                // const SizedBox(width: 5),
                                Expanded(
                                  child: InkWell(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: Image.network(
                                            widget.reply.replyMedia[2],
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) =>
                                            ReplyActionRowWithImageViewer(
                                          image: widget.reply.replyMedia![2],
                                          reply: widget.reply,
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
                        physics:const NeverScrollableScrollPhysics(),
                        crossAxisCount:
                            widget.reply.replyMedia.length > 1 ? 2 : 1,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                        children: widget.reply.replyMedia.map((image) {
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
                                builder: (context) =>
                                    ReplyActionRowWithImageViewer(
                                  image: image,
                                  reply: widget.reply,
                                ),
                              ));
                            },
                          );
                        }).toList(),
                      ),
                ],
              ),
            ),
          ],
        ),
        
        ReplyActionRow(reply: widget.reply),
        Divider(
          color: Colors.white.withOpacity(0.2),
          height: 1,
        ),
      ],
    );
  }
}
