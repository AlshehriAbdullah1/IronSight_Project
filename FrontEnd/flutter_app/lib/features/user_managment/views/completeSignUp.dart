// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/Common%20Widgets/image_helper.dart';
import 'package:iron_sight/Common%20Widgets/popUpScreen.dart';
import 'package:iron_sight/Common%20Widgets/regular_CustomTextfieldForm.dart';
import 'package:iron_sight/Common%20Widgets/regular_readonly_custom_text_field_form.dart';
import 'package:iron_sight/features/community_managment/views/community_creation_view.dart';
import 'package:iron_sight/features/user_managment/controller/user_provider.dart';
import 'package:iron_sight/features/user_managment/views/game_preference_view.dart';
import 'package:iron_sight/features/user_managment/views/profile_page_view.dart';

class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false); // Initialize with false

  void setLoading(bool isLoading) {
    state = isLoading; // Update the state
  }
}

// class BannerUploadProviderNotifier extends StateNotifier<bool> {
//   BannerUploadProviderNotifier()
//       : super(false); // Initialize with false

//   void setBannerLoading(bool newStatus) {
//     state = newStatus; // Update the state
//   }
// }
// class ImageUploadNotifier extends StateNotifier<bool> {
//   ImageUploadNotifier() : super(false); // Initialize with false

//   void setImageLoading(bool newStatus) {
//     state = newStatus; // Update the state
//   }
// }
// final bannerUploadProvider =
//     StateNotifierProvider<BannerUploadProviderNotifier, bool>((ref) {
//   return BannerUploadProviderNotifier(); // Initialize the notifier
// });


// final imageUploadProvider =
//     StateNotifierProvider<ImageUploadNotifier, bool>((ref) {
//   return ImageUploadNotifier(); // Initialize the notifier
// });
class CompleteSignUp extends ConsumerStatefulWidget {
  const CompleteSignUp({super.key});

  @override
  ConsumerState<CompleteSignUp> createState() => _CompleteSignUpState();
}

class _CompleteSignUpState extends ConsumerState<CompleteSignUp> {
  late Map<String,File?> imageFiles;
  final imageHelper = ImageHelper();

  TextEditingController userNameController = TextEditingController();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    imageFiles={
      "Profile_Picture":null,
      'Bannner':null
    };
  }

  @override
  void dispose() {
    super.dispose();

    userNameController.dispose();
    displayNameController.dispose();
    bioController.dispose();
  }


  Future<bool> uploadImages()async{
    if(imageFiles['Profile_Picture']==null || imageFiles['Banner']==null){
     return false;
    }
    else{
      // begin the uplaoding process
      // ref.read(bannerUploadProvider.notifier).setBannerLoading(true);
      // ref.read(imageUploadProvider.notifier).setImageLoading(true);

      // if not done then 
    final profileUploads = await Future.wait([
      ref.read(userProvider.notifier).uploadImages(imageFiles['Profile_Picture']!, 'Profile_Picture'),
      ref.read(userProvider.notifier).uploadImages(imageFiles['Banner']!, 'Banner'),
     ]); 
     return !(profileUploads[0] == false || profileUploads[1] == false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // print('running builld complete sign up');
    final userDetails = ref.watch(userProvider);
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
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
                    child: userDetails.user == null
                        ? const Center(
                            child: CustomProgressIndicator(),
                          )
                        : Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.topCenter,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 110),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Complete Sign Up',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge)
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: -40,
                                left: 20, // adjust this value as needed
                                child: InkWell(
                                  onTap:isLoading? null: () async {
                                    
                                    final files = await imageHelper.pickImage();
                                    if (files != null) {
                                      final croppedFile =
                                          await imageHelper.cropImage(
                                        file: files,
                                        cropStyle: CropStyle.circle,
                                      );
                                      if (croppedFile != null) {
                                        setState(() {
                                          imageFiles['Profile_Picture'] =
                                              File(croppedFile.path);
                                        });
                                      }
                                    }
                                  },
                                  child: CircleAvatar(
                                    radius: 40,
                                    backgroundImage: imageFiles['Profile_Picture'] != null
                                        ? FileImage(imageFiles['Profile_Picture']!)
                                            as ImageProvider<Object>?
                                        : ((userDetails.user != null &&
                                                    userDetails
                                                            .user!.profilepic !=
                                                        "")
                                                ? NetworkImage(userDetails
                                                    .user!.profilepic)
                                                : const AssetImage(
                                                    'assets/default_profile_pic.png'))
                                            as ImageProvider<Object>?,
                                    child: CircleAvatar(
                                      radius: 40,
                                      backgroundColor:
                                          Colors.black.withOpacity(0.5),
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
              child: SingleChildScrollView(
                child: Column(children: [
                   isLoading? const Center(child: CustomProgressIndicator(),):
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Registered Email:",
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 5),
                      ReadOnlyCustomTextFormField(
                        text: (userDetails.user != null)
                            ? userDetails.user!.email
                            : 'No email',
                        prefixIcon: Icons.email,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                      Text("Name:",
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
                      Text("Username:",
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 5),
                      CustomTextFormField(
                          controller: userNameController,
                          hintText: userDetails.user != null
                              ? userDetails.user!.username
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
                   SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.05,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          final XFile? image =
                                              await imageHelper.pickImage(
                                            source: ImageSource.gallery,
                                          );
                
                                          if (image != null) {
                                            imageFiles['Banner'] =
                                                File(image.path);
                                          }
                                        },
                                        child: const Text('Choose Banner Picture'),
                                      ),
                                      // if (isBannerLoading ==
                                      //         UploadStatus.pending &&
                                      //     uploadFilesForm['Banner'] != null)
                                      //   const CircularProgressIndicator
                                      //       .adaptive(),
                                      // if (isBannerLoading ==
                                      //         UploadStatus.success &&
                                      //     uploadFilesForm['Banner'] != null)
                                      //   const Icon(Icons.check_circle,
                                      //       color: Colors.green),
                                      // if (isBannerLoading == UploadStatus.error &&
                                      //     uploadFilesForm['Banner'] != null)
                                      //   const Icon(Icons.error_outline,
                                      //       color: Colors.red),
                                    ],
                                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  ElevatedButton(
                    child: const Text('Submit'),
                    onPressed: () {
                      // validate inputs
                      try {
                        showPopUp(context, "Are you sure you want to submit?",
                            () async {
                        ref.read(loadingProvider.notifier).setLoading(true);
                         final response=await  ref.read(userProvider.notifier).editUser( {
                            'User_Name': '@${userNameController.text}',
                            'Display_Name': displayNameController.text,
                            'Bio': bioController.text,
                          });
                            final uploadResponse= await uploadImages();
                
                           ref.read(loadingProvider.notifier).setLoading(false);
                          if(response !=null ){  
                             ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                
                          }
                          if(!uploadResponse){
                             ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(
                            content:  Text('field to upload images, try again'),
                            duration:  Duration(seconds: 2),
                          ),
                        );
                          }
                          else{
                          // navigate to user page 

                             NavigatorState cntxt=   Navigator.of(context);
                             cntxt.pop();
                             cntxt.push(MaterialPageRoute(builder: (context)=>const GamePreferenceView()));
                          }
                        });
                      } catch (e) {
                        // show snack bar of the error
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ]),
              )),
        ),
      ),
    );
  }
}
