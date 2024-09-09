import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/Common%20Widgets/regular_CustomTextfieldForm.dart';
import 'package:iron_sight/features/community_managment/views/community_creation_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:iron_sight/util/utils.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:iron_sight/features/community_managment/controller/community_provider.dart';
import 'package:iron_sight/features/community_managment/controller/post_provider.dart';
import 'package:iron_sight/features/user_managment/controller/user_provider.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/models/post.dart';

final loadingProvider = StateNotifierProvider<LoadingNotifier, bool>((ref) {
  return LoadingNotifier(); // Initialize the notifier
});

class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false); // Initialize with false

  void setLoading(bool isLoading) {
    state = isLoading; // Update the state
  }
}

class PostReplyTextField extends ConsumerStatefulWidget {
  PostReplyTextField(this.post, {Key? key}) : super(key: key);

  Post post;

  @override
  ConsumerState<PostReplyTextField> createState() => _PostReplyTextFieldState();
}

class _PostReplyTextFieldState extends ConsumerState<PostReplyTextField> {
  List<File> images = [];

  final TextEditingController _replyController = TextEditingController();
  // late Post post;

  // void shareReply () async {
  //   try{
  //     ref.read(loadingProvider.notifier).setLoading(true);
  //     String? communityId = ref.read(singleCommunityStateProvider.notifier).state.value?.id;
  //     String? postId = ref.read(communityPostsProvider.notifier).state.value?.id;

  //     if (communityId != null) {
  //       await ref.read(communityPostsProvider.notifier).shareReply(postId: widget., replyContent: _replyController.text, images: images, context: context)
  //       ;
  //     }
  //   }

  //   catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text("$e"),
  //         ),
  //       );
  //     }
  //   }

  // }

  void onPickImages() async {
    var cameraStatus = await Permission.camera.status;
    var storageStatus = await Permission.photos.status;

    if (cameraStatus.isDenied || storageStatus.isDenied) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.photos,
      ].request();

      if (statuses[Permission.camera]!.isGranted &&
          statuses[Permission.photos]!.isGranted) {
        images = await pickImages();
        // Either the permission was already granted before or the user just granted it.
        if (images.length > 4) {
          images = images.sublist(0, 4);
        }
      }
    } else if (cameraStatus.isGranted && storageStatus.isGranted) {
      images = await pickImages();
    } else {
      if (cameraStatus.isPermanentlyDenied ||
          storageStatus.isPermanentlyDenied) {
      } else if (cameraStatus.isRestricted || storageStatus.isRestricted) {
      } else if (cameraStatus.isLimited || storageStatus.isLimited) {
      } else {}
    }

    setState(() {});
// You can can also directly ask the permission about its status.
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _replyController.addListener(_onReplyChanged);

    // ref.read(communityRepliesProvider.notifier).loadReplies(widget.post.id);
  }

  void _onReplyChanged() {
    setState(() {});
  }

  int _currentIndex = 3;
  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final userImage = ref.read(userProvider.notifier).getUserProfileImage();
    return // Reply field and expand button
        Padding(
      padding: const EdgeInsets.fromLTRB(5, 5, 3, 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          CircleAvatar(
            backgroundImage: NetworkImage(widget.post.poster.profilePicture),
            radius: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                // color: const Color.fromRGBO(36, 36, 36, 1),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (images.isNotEmpty)
                    CarouselSlider(
                      options: CarouselOptions(
                        aspectRatio: 16 / 9,
                        // I dont want to be infinit
                        enableInfiniteScroll: false,
                        enlargeCenterPage: true,
                        viewportFraction: 0.4,
                        height: 70,
                        enlargeStrategy: CenterPageEnlargeStrategy.scale,
                        initialPage: 0,
                      ),
                      items: images.map((image) {
                        return Builder(
                          builder: (context) {
                            return Stack(children: [
                              Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: FileImage(image),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      images.remove(image);
                                    });
                                  },
                                ),
                              ),
                            ]);
                          },
                        );
                      }).toList(),
                    ),
                  CustomTextFormField(
                    controller: _replyController,
                    hintText: 'Reply to this post',
                    onSaved: (p0) {},
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.image,
              size: 20,
            ),
            onPressed: onPickImages,
          ),
          IconButton(
              icon: const Icon(Icons.send, size: 20),
              onPressed: _replyController.text.isNotEmpty
                  ? () async {
                      try {
                        ref.read(loadingProvider.notifier).setLoading(true);

                        String? postId = ref
                            .read(communityPostsProvider.notifier)
                            .state
                            .value
                            ?.first
                            .id;

                        if (postId != null) {
                          await ref
                              .read(communityPostsProvider.notifier)
                              .shareReply(
                                  postId: postId,
                                  replyContent: _replyController.text,
                                  images: images,
                                  context: context);

                          // final reply = await ref
                          //     .read(communityPostsProvider.notifier)
                          //     .shareReply(
                          //       postId: postId,
                          //       replyContent: _replyController.text,
                          //       images: images,
                          //       context: context,
                          //     );
                          ref.read(loadingProvider.notifier).setLoading(false);
                          ref
                              .read(communityRepliesProvider.notifier)
                              .loadReplies(postId);
                          _replyController.clear();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Post ID is null"),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {}
                      }
                    }
                  : null)
        ],
      ),
    );
  }
}
