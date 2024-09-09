import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/Common%20Widgets/image_helper.dart';
import 'package:iron_sight/Common%20Widgets/popUpScreen.dart';
import 'package:iron_sight/features/community_managment/views/community_creation_view.dart';
import 'package:iron_sight/features/user_managment/controller/user_provider.dart';
import '../../../Common Widgets/regular_CustomTextfieldForm.dart';

class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false); // Initialize with false

  void setLoading(bool isLoading) {
    state = isLoading; // Update the state
  }
}

class ProfileEditView extends ConsumerStatefulWidget {
  const ProfileEditView({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends ConsumerState<ProfileEditView>
    with SingleTickerProviderStateMixin {
  File? _ProfileImage;
  File? _BannerImage;
  final imageHelper = ImageHelper();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    displayNameController.dispose();
    userNameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<bool> uploadImages() async {
    if (_ProfileImage != null && _BannerImage != null) {
      final profileUploads = await Future.wait([
        ref
            .read(userProvider.notifier)
            .uploadImages(_ProfileImage!, 'Profile_Picture'),
        ref.read(userProvider.notifier).uploadImages(_BannerImage!, 'Banner'),
      ]);
      return !(profileUploads[0] == false || profileUploads[1] == false);
    } else if (_ProfileImage != null && _BannerImage == null) {
      return await ref
          .read(userProvider.notifier)
          .uploadImages(_ProfileImage!, 'Profile_Picture');
    } else if (_ProfileImage == null && _BannerImage != null) {
      return await ref
          .read(userProvider.notifier)
          .uploadImages(_BannerImage!, 'Banner');
    } else {
      return true;
    }
  }

  int _currentIndex = 3; //For the bottom navigation bar

  @override
  Widget build(BuildContext context) {
    final userDetails = ref.watch(userProvider);
    final isLoading = ref.watch(loadingProvider);
    return Stack(
      children: [Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/background.jpg'), fit: BoxFit.cover),
          ),
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: MediaQuery.of(context).size.height * 0.2,
                  // the property below can be refactored to handle profile view
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const <StretchMode>[
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground
                    ],
                    background: Padding(
                      padding: const EdgeInsets.only(
                          bottom: 40), // adjust this value as needed
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          SizedBox.expand(
                            child: Container(
                              decoration: BoxDecoration(
                                  image: _BannerImage != null
                                      ? DecorationImage(
                                          image: FileImage(_BannerImage!))
                                      : null),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_enhance_rounded,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                  onPressed: () async {
                                    final files = await imageHelper.pickImage();
                                    if (files != null) {
                                      final croppedFile =
                                          await imageHelper.cropImage(
                                        file: files,
                                        cropStyle: CropStyle.rectangle,
                                        aspectRatio: const CropAspectRatio(
                                            ratioX: 1, ratioY: 0.41),
                                      );
                                      if (croppedFile != null) {
                                        setState(() {
                                          _BannerImage = File(croppedFile.path);
                                        });
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -40,
                            left: 20, // adjust this value as needed
                            child: InkWell(
                              onTap: () async {
                                final files = await imageHelper.pickImage();
                                if (files != null) {
                                  final croppedFile = await imageHelper.cropImage(
                                    file: files,
                                    cropStyle: CropStyle.circle,
                                  );
                                  if (croppedFile != null) {
                                    setState(() {
                                      _ProfileImage = File(croppedFile.path);
                                    });
                                  }
                                }
                              },
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: _ProfileImage != null
                                    ? FileImage(_ProfileImage!)
                                    : null,
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.black.withOpacity(0.5),
                                  child: const Icon(
                                    Icons.camera_enhance_rounded,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  iconTheme: const IconThemeData(size: 20.0),
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.6)),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/background.jpg'),
                      fit: BoxFit.cover),
                ),
                child: Column(children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Display Name:",
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 5),
                      CustomTextFormField(
                          controller: displayNameController,
                          hintText: userDetails.user != null
                              ? userDetails.user!.displayName
                              : '',
                          prefixIcon: Icons.person,
                          onSaved: (value) {}),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("User Name:",
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 5),
                      CustomTextFormField(
                          controller: userNameController,
                          hintText: userDetails.user != null
                              ? userDetails.user!.username.substring(1)
                              : '',
                          prefixIcon: Icons.person,
                          onSaved: (value) {}),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Bio:",
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 5),
                      CustomTextFormField(
                          controller: bioController,
                          hintText: userDetails.user != null
                              ? userDetails.user!.bio
                              : '',
                          prefixIcon: Icons.badge,
                          onSaved: (value) {}),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  ElevatedButton(
                    child: const Text('Submit'),
                    onPressed: () {
                      showPopUp(context, "Are you sure you want to submit?",
                          () async {
                        // If the user has changed any of the fields, update the user
                        if (userDetails.user != null) {
                          if ((displayNameController.text !=
                                      userDetails.user!.displayName &&
                                  displayNameController.text != "") ||
                              (userNameController.text !=
                                      userDetails.user!.username.substring(1) &&
                                  userNameController.text != "") ||
                              (bioController.text != userDetails.user!.bio &&
                                  bioController.text != "") ||
                              _ProfileImage != null ||
                              _BannerImage != null) {


                                ref.read(loadingProvider.notifier).setLoading(true);
                            final updateResult = await Future.wait([
                              ref.read(userProvider.notifier).editUser({
                                if(userNameController.text != "") 
                                'User_Name': userNameController.text,
                                if(displayNameController.text != "")
                                'Display_Name': displayNameController.text,
                                if(bioController.text != "")
                                'Bio': bioController.text,
                              }),
                              uploadImages()
                            ]);
                             ref.read(loadingProvider.notifier).setLoading(false);
                            if (updateResult[0] != null ||
                                updateResult[1] == false) {
                              // Show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(content: Text('An error occurred while updating the profile.${updateResult[0]?? ""}')),
                              );
                            } else {
                              Navigator.of(context).pop();
                            }
                          }
                        }
                      });
                    },
                  ),
                ])),
          ),
        ),
      ),
       if (isLoading)
        Container(
          color: Colors.black.withOpacity(0.5),
          child: const Center(
            child: CustomProgressIndicator(),
          ),
        ),
      ]
    );
  }
}
