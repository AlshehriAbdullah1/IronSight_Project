import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/APIs/user_api_client.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/features/community_managment/widgets/community_image_viewer.dart';
import 'package:iron_sight/features/community_managment/controller/community_provider.dart';
import 'package:iron_sight/features/community_managment/controller/post_provider.dart';
import 'package:iron_sight/features/community_managment/views/community_page_view.dart';
import 'package:iron_sight/features/community_managment/views/post_view.dart';
import 'package:iron_sight/features/community_managment/widgets/postActionRow.dart';
import 'package:iron_sight/features/user_managment/controller/auth_provider.dart';
import 'package:iron_sight/features/user_managment/controller/user_provider.dart';
import 'package:iron_sight/util/utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:image_picker/image_picker.dart';
// final TextEditingController _controller = TextEditingController();
// final ValueNotifier<bool> _isButtonEnabled = ValueNotifier<bool>(false);

final loadingProvider = StateNotifierProvider<LoadingNotifier, bool>((ref) {
  return LoadingNotifier(); // Initialize the notifier
});

class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false); // Initialize with false

  void setLoading(bool isLoading) {
    state = isLoading; // Update the state
  }
}

class CreatePost extends ConsumerStatefulWidget {
  const CreatePost({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends ConsumerState<CreatePost> {
  final postTextController = TextEditingController();
  List<File> images = [];

  @override
  void initState() {
    super.initState();
    // postTextController.addListener(() {
    //   isButtonEnabled.value = postTextController.text.isNotEmpty;
    // });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    postTextController.dispose();
  }

  void sharePost() async {
    // ref.read(postProvider)(
    //       images: images,
    //       text: postTextController.text,
    //       context: context,
    //     );
    try {
      ref.read(loadingProvider.notifier).setLoading(true);
      String? communityId =
          ref.read(singleCommunityStateProvider.notifier).state.value?.id;

      if (communityId != null) {
        await ref.read(communityPostsProvider.notifier).sharePost(
            postContent: postTextController.text,
            images: images,
            context: context,
            communityId: communityId);
        ref.read(loadingProvider.notifier).setLoading(false);
        ref.read(communityPostsProvider.notifier).getPosts(communityId);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text("Community is not specificed, please try again later"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$e"),
          ),
        );
      }
    }

    ref.read(loadingProvider.notifier).setLoading(false);
  }

  void onClose() {
    Navigator.pop(context);
  }

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
      }
    } else if (cameraStatus.isGranted && storageStatus.isGranted) {
      images = await pickImages();
    } else {
      if (cameraStatus.isPermanentlyDenied ||
          storageStatus.isPermanentlyDenied) {
      } else if (cameraStatus.isRestricted || storageStatus.isRestricted) {
      } else if (cameraStatus.isLimited || storageStatus.isLimited) {
      } else {
      }
    }

    setState(() {});
// You can can also directly ask the permission about its status.
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/background.jpg'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(24, 2, 49, 1),
          centerTitle: false,
          leadingWidth: 100,
          leading: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium, // Adjust the font size here
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  right: 10.0), // Add padding to the right
              child: ElevatedButton(
                onPressed: postTextController.text.isNotEmpty
                    ? () {
                        // Handle post action here
                        sharePost();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(
                      91, 41, 143, 1), // This is the button color
                ),
                child: const Text(
                  'Post',
                  style:
                      TextStyle(color: Colors.white), // This is the text color
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0), // Add padding
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment
                    .center, // This will center the children vertically
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                            ref.read(userProvider.notifier).getProfileImage),
                        radius: 25,
                      ),
                    ],
                  ),
                  const SizedBox(
                      width: 10), // Add space between the avatar and the text
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10.0, bottom: 10.0, right: 10.0, left: 10.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              ref.read(userProvider.notifier).getUsername,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                      ],
                    ), // Add padding
                  )
                ],
              ),
              isLoading
                  ? const CustomProgressIndicator()
                  : Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 10,
                            bottom: 10,
                            left: 20,
                            right: 10), // Add padding
                        child: TextField(
                          controller: postTextController,
                          maxLines: null,
                          maxLength:
                              255, // This allows the TextField to expand as the user types
                          decoration: const InputDecoration(
                            border: InputBorder.none, // This removes the border
                            hintText: "What's on your mind?",
                          ),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                    ),
              if (images.isNotEmpty)
                Expanded(
                  child: CarouselSlider(
                    items: images.map(
                      (file) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Stack(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                // margin: const EdgeInsets.symmetric(
                                //   horizontal: 5,
                                // ),
                                child: Image.file(file),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        images.remove(file);
                                      });
                                    },
                                    child: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ).toList(),
                    options: CarouselOptions(
                      height: 400,
                      enableInfiniteScroll: false,
                    ),
                  ),
                )
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.only(bottom: 10),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey,
                width: 0.3,
              ),
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding:
                    const EdgeInsets.all(8.0).copyWith(left: 15, right: 15),
                child: InkWell(
                    onTap: onPickImages,
                    child: const Icon(
                      Icons.camera_alt,
                      size: 60,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
