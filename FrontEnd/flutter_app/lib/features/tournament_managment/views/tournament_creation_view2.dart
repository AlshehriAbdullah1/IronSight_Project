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
import 'package:iron_sight/features/tournament_managment/controller/tournament_provider.dart';
import 'package:iron_sight/features/tournament_managment/views/tournament_management_view.dart';
import 'package:iron_sight/features/user_managment/controller/user_provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../../../Common Widgets/regular_CustomTextfieldForm.dart';

final ownerProvider = StateProvider<bool>((ref) => false);

enum TournamentType {
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




final _formkey = GlobalKey<FormState>();

class TournamentCreationView2 extends ConsumerStatefulWidget {
  final String tournamentId;

 const TournamentCreationView2({Key? key,required this.tournamentId})
      : super(key: key);

  @override
  ConsumerState<TournamentCreationView2> createState() => _TournamentCreationView2State();
}

class _TournamentCreationView2State extends ConsumerState<TournamentCreationView2>
    with SingleTickerProviderStateMixin {
  String? _tournamentThumbnailImage;
  String? _tournamentBannerImage;
  final imageHelper = ImageHelper();
    final pendingProvider = StateProvider<bool>((ref) => false);
  final ImagePicker _picker = ImagePicker();
  late Map<String, File?> uploadFilesForm;

 

  late Map<String, dynamic> editCommunityForm;

  @override
  void initState() {
    super.initState();
    super.initState();
    uploadFilesForm = {'Banner': null, "Thumbnail": null};
    if(ref.read(singleTournamentStateProvider).value!=null){
      _tournamentBannerImage= ref.read(singleTournamentStateProvider).value!.banner;
      _tournamentThumbnailImage= ref.read(singleTournamentStateProvider).value!.thumbnail;
    }
    // I want to use the File to add image link inside it 

  }

  void dispose() {
    super.dispose();

  }

  Future<void> uploadImagesForm() async {
    ref.read(loadingProvider.notifier).setLoading(true);
    if(uploadFilesForm['Banner']!=null && uploadFilesForm['Thumbnail']!=null){
                   ref
          .read(bannerUploadProvider.notifier)
          .setBannerLoading(UploadStatus.pending);
          ref
          .read(thumbnailUploadProvider.notifier)
          .setThumbnailLoading(UploadStatus.pending);

          await ref.read(singleTournamentStateProvider.notifier).uploadTournamentPictures(uploadFilesForm['Banner']!, uploadFilesForm['Thumbnail']!);

                     ref
          .read(bannerUploadProvider.notifier)
          .setBannerLoading(UploadStatus.success);
          ref
          .read(thumbnailUploadProvider.notifier)
          .setThumbnailLoading(UploadStatus.success);

    }
    else if (uploadFilesForm['Banner'] != null) {
      try {
          ref
          .read(bannerUploadProvider.notifier)
          .setBannerLoading(UploadStatus.pending);

      await ref
          .read(singleTournamentStateProvider.notifier)
          .uploadTournamentBanner(uploadFilesForm['Banner']!);
      ref
          .read(bannerUploadProvider.notifier)
          .setBannerLoading(UploadStatus.success);
       
      } catch (e) {
         ref
            .read(bannerUploadProvider.notifier)
            .setBannerLoading(UploadStatus.error);
      
      }
    }
    else if (uploadFilesForm['Thumbnail'] != null) {
      try {
          ref
          .read(thumbnailUploadProvider.notifier)
          .setThumbnailLoading(UploadStatus.pending);

    await ref
          .read(singleTournamentStateProvider.notifier)
          .uploadTournamentThumbnail(uploadFilesForm['Thumbnail']!);

      
        ref
            .read(thumbnailUploadProvider.notifier)
            .setThumbnailLoading(UploadStatus.success);
      } catch (e) {
         ref
            .read(thumbnailUploadProvider.notifier)
            .setThumbnailLoading(UploadStatus.error);
      }
    
   
       
      
    }
   

    ref.read(loadingProvider.notifier).setLoading(false);
     NavigatorState cntxt = Navigator.of(context);
  cntxt.pop();
    if (mounted) {
      cntxt.push(MaterialPageRoute(builder: (context) {
      return   TournamentManagementView(tournamentId: widget.tournamentId,);
      },));
    }
   
  }
  int _currentIndex = 3; //For the bottom navigation bar

  @override
  Widget build(BuildContext context) {
    
    final tournamentDetails = ref.watch(singleTournamentStateProvider);

    double screenWidth = MediaQuery.of(context).size.width;
    // final userDetails = ref.watch(userStateProvider);
    final isLoading = ref.watch(loadingProvider);
    final isThumbnailLoading = ref.watch(thumbnailUploadProvider);
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
                                image: uploadFilesForm['Banner'] == null
                                    ? DecorationImage(
                                        image: NetworkImage(_tournamentBannerImage!))
                                    : DecorationImage(image:FileImage(uploadFilesForm['Banner']!))),
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
                      ],
                    ),
                  ),
                ),
                backgroundColor: Colors.transparent,
                iconTheme: const IconThemeData(size: 20.0),
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
                                                Text('''Tournament's Thumbnail Photo''',
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
                          Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Center(
                                  child: ElevatedButton(
                                onPressed: () async {
                                  
                                
                                     uploadImagesForm();
                                  
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
