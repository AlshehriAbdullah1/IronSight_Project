import 'dart:io';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/features/community_managment/controller/community_provider.dart';
import 'package:iron_sight/features/community_managment/views/community_creation_view_2.dart';
import 'package:iron_sight/Common%20Widgets/regular_CustomTextfieldForm.dart';
import 'package:iron_sight/features/community_managment/views/community_page_view.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _formkey = GlobalKey<FormState>();

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

// final submittedProvider = StateNotifierProvider<SubmittedProviderNotifier, bool>((ref) {
//   return SubmittedProviderNotifier(); // Initialize the notifier
// });

// class SubmittedProviderNotifier extends StateNotifier<bool> {
//   SubmittedProviderNotifier() : super(false); // Initialize with false

//   void setSubmitted(bool isSubmitted) {
//     state = isSubmitted; // Update the state
//   }
// }

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

class CommunityCreationView2 extends ConsumerStatefulWidget {
  const CommunityCreationView2({super.key});

  @override
  ConsumerState<CommunityCreationView2> createState() =>
      _CommunityCreationView2State();
}

class _CommunityCreationView2State
    extends ConsumerState<CommunityCreationView2> {
  final pendingProvider = StateProvider<bool>((ref) => false);
  final ImagePicker _picker = ImagePicker();
  late Map<String, File?> uploadFilesForm;

  Future<void> uploadImagesForm() async {
    var success=true;
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
        success=false;
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
          success=false;
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
          success=false;
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
        if(communityId!=null && success){
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return  CommunityView(communityId: communityId);
          },
        ));
        } else{
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error uploading community images, try again'),
            ),
          );
        }
      });
      
    }
  }

  @override
  void initState() {
    super.initState();
    uploadFilesForm = {'Image': null, 'Banner': null, "Thumbnail": null};
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final isLoading = ref.watch(loadingProvider);
    final isImageLoading = ref.watch(imageUploadProvider);
    final isBannerLoading = ref.watch(bannerUploadProvider);
    final isThumbnailLoading = ref.watch(thumbnailUploadProvider);

    // final isSubmitted = ref.watch(submittedProvider);

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/background.jpg'), fit: BoxFit.cover),
      ),
      child: DefaultTabController(
          initialIndex: 0,
          length: 4,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              toolbarHeight: MediaQuery.of(context).size.height * 0.1,
              flexibleSpace: Padding(
                padding:
                    EdgeInsets.only(top: 22.0), // Adjust the value as needed
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/IronSightLogo.png'),
                    ),
                  ),
                ),
              ),
            ),
            body: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 0),
                    child: Form(
                      key: _formkey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 22,
                          ),
                          Text('Create a New Community',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(
                            height: 33,
                          ),
                          Text('''Community's Main Photo''',
                              style: Theme.of(context).textTheme.titleMedium),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(' ',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
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
                                                source: ImageSource.gallery);

                                        if (image != null) {
                                          uploadFilesForm['Image'] =
                                              File(image.path);
                                        }
                                      },
                                      child: const Text('Choose Main Picture'),
                                    ),
                                    if (isImageLoading ==
                                            UploadStatus.pending &&
                                        uploadFilesForm['Image'] != null)
                                      const CustomProgressIndicator(),
                                    if (isImageLoading ==
                                            UploadStatus.success &&
                                        uploadFilesForm['Image'] != null)
                                      const Icon(Icons.check_circle,
                                          color: Colors.green),
                                    if (isImageLoading == UploadStatus.error &&
                                        uploadFilesForm['Image'] != null)
                                      const Icon(Icons.error_outline,
                                          color: Colors.red),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 33,
                          ),
                          Text('''Community's Banner Photo''',
                              style: Theme.of(context).textTheme.titleMedium),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Community Name',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        final XFile? image =
                                            await _picker.pickImage(
                                          source: ImageSource.gallery,
                                        );

                                        if (image != null) {
                                          uploadFilesForm['Banner'] =
                                              File(image.path);
                                        }
                                      },
                                      child: Text('Choose Banner Picture'),
                                    ),
                                    if (isBannerLoading ==
                                            UploadStatus.pending &&
                                        uploadFilesForm['Banner'] != null)
                                      const CustomProgressIndicator(),
                                    if (isBannerLoading ==
                                            UploadStatus.success &&
                                        uploadFilesForm['Banner'] != null)
                                      const Icon(Icons.check_circle,
                                          color: Colors.green),
                                    if (isBannerLoading == UploadStatus.error &&
                                        uploadFilesForm['Banner'] != null)
                                      const Icon(Icons.error_outline,
                                          color: Colors.red),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 33,
                          ),
                          Text('''Community's Thumbnail Photo''',
                              style: Theme.of(context).textTheme.titleMedium),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Community Thumbnail photo',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
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
                            height: 33,
                          ),
                          Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Center(
                                  child: ElevatedButton(
                                onPressed: () {
                                  uploadImagesForm();
                                },
                                child: isLoading
                                    ? const CustomProgressIndicator()
                                    : const Text('Submit'),
                              )))
                        ],
                      ),
                    ))),
          )),
    );
  }
}
