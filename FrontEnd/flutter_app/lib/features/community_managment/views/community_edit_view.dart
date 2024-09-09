import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/Common%20Widgets/image_helper.dart';
import 'package:iron_sight/Common%20Widgets/popUpScreen.dart';
import 'package:iron_sight/features/community_managment/controller/community_provider.dart';
import 'package:iron_sight/features/community_managment/views/community_page_view.dart';
import 'package:iron_sight/features/user_managment/controller/user_provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../../../Common Widgets/regular_CustomTextfieldForm.dart';

final ownerProvider = StateProvider<bool>((ref) => false);

enum CommunityType {
  private,
  public,
}

enum UploadStatus {
  pending,
  success,
  error,
  waiting,
}

final loadingProvider = StateNotifierProvider<LoadingNotifier, bool>((ref) {
  return LoadingNotifier(); // Initialize the notifier
});

class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false); // Initialize with false

  void setLoading(bool isLoading) {
    state = isLoading; // Update the state
  }
}

class CommunityTypeNotifier extends StateNotifier<CommunityType> {
  CommunityTypeNotifier() : super(CommunityType.public);

  void setCommunityType(CommunityType type) {
    state = type;
  }
}


final imageUploadProvider =
    StateNotifierProvider<ImageUploadNotifier, UploadStatus>((ref) {
  return ImageUploadNotifier(); // Initialize the notifier
});

class ImageUploadNotifier extends StateNotifier<UploadStatus> {
  ImageUploadNotifier() : super(UploadStatus.waiting); // Initialize with false

  void setImageLoading(UploadStatus newStatus) {
    state = newStatus; // Update the state
  }
}

final bannerUploadProvider =
    StateNotifierProvider<BannerUploadProviderNotifier, UploadStatus>((ref) {
  return BannerUploadProviderNotifier(); // Initialize the notifier
});

class BannerUploadProviderNotifier extends StateNotifier<UploadStatus> {
  BannerUploadProviderNotifier()
      : super(UploadStatus.waiting); // Initialize with false

  void setBannerLoading(UploadStatus newStatus) {
    state = newStatus; // Update the state
  }
}


final thumbnailUploadProvider =
    StateNotifierProvider<ThumbnailUploadNotifier, UploadStatus>((ref) {
  return ThumbnailUploadNotifier(); // Initialize the notifier
});

class ThumbnailUploadNotifier extends StateNotifier<UploadStatus> {
  ThumbnailUploadNotifier()
      : super(UploadStatus.waiting); // Initialize with false

  void setThumbnailLoading(UploadStatus newStatus) {
    state = newStatus; // Update the state
  }
}

final selectedCommunityTypeProvider =
    StateNotifierProvider<CommunityTypeNotifier, CommunityType>((ref) {
  return CommunityTypeNotifier();
});

final _formkey = GlobalKey<FormState>();

class CommunityEditView extends ConsumerStatefulWidget {
  final File? communityImage;
  final File? bannerImage;
  final String communityId;

  CommunityEditView({Key? key,required this.communityId, this.communityImage, this.bannerImage})
      : super(key: key);

  @override
  ConsumerState<CommunityEditView> createState() => _communityEditViewState();
}

class _communityEditViewState extends ConsumerState<CommunityEditView>
    with SingleTickerProviderStateMixin {
  File? _communityImage;
  File? _BannerImage;
  final imageHelper = ImageHelper();
    final pendingProvider = StateProvider<bool>((ref) => false);
  final ImagePicker _picker = ImagePicker();
  late Map<String, File?> uploadFilesForm;

  final TextEditingController _CommunityNameController =
      TextEditingController();
  final TextEditingController _CommunityPasswordController =
      TextEditingController();
  final TextEditingController _CommunityGenreController =
      TextEditingController();
  final TextEditingController _CommunityDescriptionController =
      TextEditingController();

  late Map<String, dynamic> editCommunityForm;

  @override
  void initState() {
    super.initState();
    _communityImage = widget.communityImage;
    _BannerImage = widget.bannerImage;
    super.initState();
    uploadFilesForm = {'Image': null, 'Banner': null, "Thumbnail": null};
    editCommunityForm = {'isPrivate': false, 'Password': ''};
  }

  void dispose() {
    super.dispose();
    _CommunityNameController.dispose();
    _CommunityDescriptionController.dispose();
    _CommunityGenreController.dispose();
  }

  Future<void> uploadImagesForm() async {
    ref.read(loadingProvider.notifier).setLoading(true);


    if (uploadFilesForm['Image'] != null) {
      ref
          .read(imageUploadProvider.notifier)
          .setImageLoading(UploadStatus.pending);

      bool response = await ref
          .read(singleCommunityStateProvider.notifier)
          .uploadCommunityPictures(uploadFilesForm['Image']!);
      if (response) {
        ref
            .read(imageUploadProvider.notifier)
            .setImageLoading(UploadStatus.success);
      } else {
        ref
            .read(imageUploadProvider.notifier)
            .setImageLoading(UploadStatus.error);
      }
    }
    if (uploadFilesForm['Banner'] != null) {
      ref
          .read(bannerUploadProvider.notifier)
          .setBannerLoading(UploadStatus.pending);

      bool response = await ref
          .read(singleCommunityStateProvider.notifier)
          .uploadCommunityBanner(uploadFilesForm['Banner']!);
      ref
          .read(bannerUploadProvider.notifier)
          .setBannerLoading(UploadStatus.pending);
      if (response) {
        ref
            .read(bannerUploadProvider.notifier)
            .setBannerLoading(UploadStatus.success);
      } else {
        ref
            .read(bannerUploadProvider.notifier)
            .setBannerLoading(UploadStatus.error);
      }
    }
    if (uploadFilesForm['Thumbnail'] != null) {
      ref
          .read(thumbnailUploadProvider.notifier)
          .setThumbnailLoading(UploadStatus.pending);

      bool response = await ref
          .read(singleCommunityStateProvider.notifier)
          .uploadCommunityThumbnail(uploadFilesForm['Thumbnail']!);
      ref
          .read(thumbnailUploadProvider.notifier)
          .setThumbnailLoading(UploadStatus.pending);
      if (response) {
        ref
            .read(thumbnailUploadProvider.notifier)
            .setThumbnailLoading(UploadStatus.success);
      } else {
        ref
            .read(thumbnailUploadProvider.notifier)
            .setThumbnailLoading(UploadStatus.error);
      }
    }
    ref.read(loadingProvider.notifier).setLoading(false);
    if (mounted) {
      // do this after 1.5 seconds
      Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
        String? communityId= ref.read(singleCommunityStateProvider.notifier).getCurrentCommunityId();  
        if(widget.communityId!=null){
        ref.read(singleCommunityStateProvider.notifier).getCommunity(widget.communityId)
          .then((value) => Navigator.pop(
                context,
                ));
        } 
        else{
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error editing community'),
            ),
          );
        }
      });
      
    }
  }
  int _currentIndex = 3; //For the bottom navigation bar


  // Future<void>  editCommunity()async{ 
  //   String? communityId= ref.read(communityStateProvider.notifier).state.value?.id;
  //   await ref.read(communityStateProvider.notifier).editCommunity(communityId!,editCommunityForm);
    
    
    // if(communityId !=null){
    //   // naviage to second page

    //   Navigator.of(context).push(MaterialPageRoute(builder: (context) {
    //     return const CommunityCreationView2();
    //   },));
    // }
    // else{
    //   Platform.isIOS? showCupertinoDialog(context: context, builder: (context) {
    //     // pop up error message
    //     return CupertinoAlertDialog(
    //       title:const  Text("Error"),
    //       content:const  Text("Could not create community"),
    //       actions: <Widget>[
    //         CupertinoDialogAction(
    //           child:const  Text("Ok"),
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //         ),
    //       ],
    //     );
    //   },):null;

    //   Platform.isAndroid ? showDialog(
    //     context: context,
    //     builder: (context) {
    //       // pop up error message
    //       return AlertDialog(
    //         title:const  Text("Error"),
    //         content:const  Text("Could not create community"),
    //         actions: <Widget>[
    //           TextButton(
    //             child:const Text("Ok"),
    //             onPressed: () {
    //               Navigator.of(context).pop();
    //             },
    //           ),
    //         ],
    //       );
    //     },
    //   ) : null;
    // }

  // }
  @override
  Widget build(BuildContext context) {

    final communityDetails = ref.watch(singleCommunityStateProvider);

    double screenWidth = MediaQuery.of(context).size.width;
    // final userDetails = ref.watch(userStateProvider);
    final communityTypeState = ref.watch(selectedCommunityTypeProvider);
    final isThumbnailLoading = ref.watch(thumbnailUploadProvider);
    final isLoading = ref.watch(loadingProvider);
    return Scaffold(
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
                // the property below can be refactored to handle community view
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
                                        uploadFilesForm["Banner"] = File(croppedFile.path);
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
                                    uploadFilesForm["Image"] = File(croppedFile.path);
                                  });
                                }
                              }
                            },
                            child: CircleAvatar(
                              radius: 40,
                              backgroundImage: _communityImage != null
                                  ? FileImage(_communityImage!)
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
                        Navigator.of(context).pop();
                        // Navigator.of(context).push(MaterialPageRoute(
                        // builder: (context) {
                        // return  CommunityView(communityId: widget.communityId);
                        // },
                        // ));
                      },
                    ),
                  ),
                ),
              ),
            ];
          },
          body: SingleChildScrollView(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0),
                child: Form(
                  key: _formkey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                                                      const SizedBox(
                                  height: 5,
                                ),
                                                Text('''Community's Thumbnail Photo''',
                              style: Theme.of(context).textTheme.titleMedium),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        final XFile? image =
                                            await _picker.pickImage(
                                          source: ImageSource.gallery,
                                         
                                        );

                                        if (image != null) {
                                          uploadFilesForm['Thumbnail'] =
                                              File(image.path);
                                        }
                                      },
                                      child: const Text(
                                          'Choose Thumbnail Picture'),
                                    ),
                                    if (isThumbnailLoading ==
                                            UploadStatus.pending &&
                                        uploadFilesForm['Thumbnail'] != null)
                                      const CustomProgressIndicator(),

                                    if (isThumbnailLoading ==
                                            UploadStatus.success &&
                                        uploadFilesForm['Thumbnail'] != null)
                                      const Icon(Icons.check_circle,
                                          color: Colors.green),
                                    if (isThumbnailLoading ==
                                            UploadStatus.error &&
                                        uploadFilesForm['Thumbnail'] != null)
                                      const Icon(Icons.error_outline,
                                          color: Colors.red),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      const SizedBox(
                        height: 22,
                      ),
                      Text('Edit Your Community',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(
                        height: 22,
                      ),
                      Text('Privacy',
                          style: Theme.of(context).textTheme.titleMedium),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Private or Public',
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(
                              height: 5,
                            ),
                            Material(
                              elevation: 10,
                              shadowColor: Colors.black,
                              borderRadius: BorderRadius.circular(15),
                              child: ToggleSwitch(
                                key:
                                    ValueKey<CommunityType>(communityTypeState),
                                initialLabelIndex:
                                    communityTypeState == CommunityType.private
                                        ? 1
                                        : 0,
                                minWidth: screenWidth * 0.4,
                                cornerRadius: 15,
                                activeFgColor: Colors.white,
                                inactiveBgColor:
                                    const Color.fromRGBO(36, 36, 36, 1),
                                inactiveFgColor: Colors.white,
                                totalSwitches: 2,
                                labels: const ['Public', 'Private'],
                                icons: const [Icons.lock_open, Icons.lock],
                                activeBgColors: const [
                                  [Color.fromRGBO(89, 54, 183, 1)],
                                  [Color.fromRGBO(89, 54, 183, 1)]
                                ],
                                onToggle: (int? index) {
                                  ref
                                      .read(selectedCommunityTypeProvider
                                          .notifier)
                                      .setCommunityType(index == 0
                                          ? CommunityType.public
                                          : CommunityType.private);

                                  // print('$index is the index and we are chaning the type to ${(index == 0 ? CommunityType.public : CommunityType.private).toString()} \n\n\n this logic should result to form with ${(communityTypeState== CommunityType.private ? 'Private' : 'Public')}');

                                  // editCommunityForm= {};
                                  // print(
                                  //   'selected community type is ${communityTypeState.toString()}'
                                  // );
                                  // editCommunityForm['Type'] =
                                  //     communityTypeState== CommunityType.private ? 'Private' : 'Public';
                                  WidgetsBinding.instance!
                                      .addPostFrameCallback((_) {
                                    // print('$index is the index and we are changing the type to ${(index == 0 ? CommunityType.public : CommunityType.private).toString()} \n\n\n this logic should result to form with ${(communityTypeState== CommunityType.private ? 'Private' : 'Public')}');

                                    editCommunityForm = {};
                                  
                                    editCommunityForm['isPrivate'] = ref
                                                .read(
                                                    selectedCommunityTypeProvider
                                                        .notifier)
                                                .state ==
                                            CommunityType.private
                                        ? true
                                        : false;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (communityTypeState == CommunityType.private)
                        const SizedBox(
                          height: 33,
                        ),
                      if (communityTypeState == CommunityType.private)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Community Password',
                                style: Theme.of(context).textTheme.titleMedium),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  CustomTextFormField(
                                    controller: _CommunityPasswordController,
                                    hintText:
                                        'Enter a password for your community',
                                    prefixIcon: Icons.password,
                                    obscureText: true,
                                    validator: (p0) {
                                      if (p0.length < 4) {
                                        editCommunityForm['Password']=communityDetails.value?.password;
                                        return 'The password must be at least 4 characters';
                                      }
                                      if (p0.length > 30) {
                                        editCommunityForm['Password']=communityDetails.value?.password;
                                        return 'The password must not be more than 30 characters';
                                      }
                                      editCommunityForm['Password']=communityDetails.value?.password;
                                    },
                                    onSaved: (p0) {
                                      if(p0.isNotEmpty){
                                        editCommunityForm['Password'] = p0;
                                      }
                                      else{
                                        editCommunityForm['Password']=communityDetails.value?.password;
                                      }
                                    },
                                    isEditCommunity: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(
                        height: 33,
                      ),
                      Text('Community Name',
                          style: Theme.of(context).textTheme.titleMedium),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            CustomTextFormField(
                              controller: _CommunityNameController,
                              hintText: communityDetails.value?.communityName ?? 'Community Name',
                              prefixIcon: Icons.wysiwyg,
                              validator: (p0) {
                                if (p0.length < 3) {
                                  editCommunityForm['Community_Name']=communityDetails.value?.communityName;
                                  return 'Community name is too short';
                                }
                                if (p0.length > 60) {
                                  editCommunityForm['Community_Name']=communityDetails.value?.communityName;
                                  return 'Community name is too long';
                                }
                                editCommunityForm['Community_Name']=communityDetails.value?.communityName;
                              },
                              onSaved: (p0) {
                                editCommunityForm['Community_Name'] = p0;
                              },
                              isEditCommunity: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 33,
                      ),
                      Text('Community Tag',
                          style: Theme.of(context).textTheme.titleMedium),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            CustomTextFormField(
                              controller: _CommunityGenreController,
                              hintText: 
                                communityDetails.value?.communityTag ?? 'Community Tag',
                              prefixIcon: Icons.tag,
                              validator: (p0) {
                                if('#${p0}' == communityDetails.value?.communityTag) return null; 
                                
                                if (p0.length < 3) {
                                  editCommunityForm['Community_Tag']=communityDetails.value?.communityTag;
                                  return 'Community tag is too short';
                                }
                                if (p0.length > 20) {
                                  editCommunityForm['Community_Tag']=communityDetails.value?.communityTag;
                                  return 'Community tag is too long';
                                }
                                editCommunityForm['Community_Tag']=communityDetails.value?.communityTag;
                              },
                              onSaved: (p0) {
                                editCommunityForm['Community_Tag'] = p0;
                              },
                              isEditCommunity: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 33,
                      ),
                      Text('Community Description',
                          style: Theme.of(context).textTheme.titleMedium),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            CustomTextFormField(
                              
                              controller: _CommunityDescriptionController,
                              hintText: 
                                communityDetails.value?.description??'A brief description of your community',
                              prefixIcon: Icons.description,
                              validator: (p0) {
                                if (p0.length > 500) {
                                  editCommunityForm['Description']=communityDetails.value?.description;
                                  return 'Community description is too long';
                                }
                                editCommunityForm['Description']=communityDetails.value?.description;
                              },
                              onSaved: (p0) {
                                editCommunityForm['Description'] = p0!;
                              },
                              isEditCommunity: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 33,
                      ),
                          Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Center(
                                  child: ElevatedButton(
                                onPressed: () async {
                                  // if(editCommunityForm['Community_Name']==null){
                                  //   editCommunityForm['Community_Name']=communityDetails.value?.communityName;
                                  // }
                                  // if(editCommunityForm['Community_Tag']==null){
                                  //   editCommunityForm['Community_Tag']=communityDetails.value?.communityTag;
                                  // }
                                  // if(editCommunityForm['Description']==null){
                                  //   editCommunityForm['Description']=communityDetails.value?.description;
                                  // }
                                  if (_formkey.currentState!.validate()) {
                                    _formkey.currentState!.save();
                                  }
                                  //   String? communityId= ref.read(communityStateProvider.notifier).state.value?.id;
                                  // editCommunityForm['Community_Id'] = widget.communityId;
                                  // If no changes were made don't submit
                                  if (editCommunityForm['Community_Name'] == communityDetails.value?.communityName &&
                                      editCommunityForm['Community_Tag'] == communityDetails.value?.communityTag &&
                                      editCommunityForm['Description'] == communityDetails.value?.description &&
                                      editCommunityForm['isPrivate'] == communityDetails.value?.isPrivate &&
                                      editCommunityForm['Password'] == communityDetails.value?.password &&
                                      uploadFilesForm['Image'] == null &&
                                      uploadFilesForm['Banner'] == null &&
                                      uploadFilesForm['Thumbnail'] == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('No changes were made'),
                                      ),
                                    );
                                    // uploadImagesForm();
                                    return;
                                  }
                                  else{
                                    await ref.read(singleCommunityStateProvider.notifier)
                                    .editCommunity(editCommunityForm);
                                    uploadImagesForm();
                                  }
                                },
                                child: isLoading
                                    ? const CustomProgressIndicator()
                                    : const Text('Submit'),
                              )))
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
