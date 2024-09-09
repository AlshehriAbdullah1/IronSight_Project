// import 'dart:io';
// import 'dart:math';
// import 'package:iron_sight/features/tournament_managment/controller/tournament_provider.dart';
// import 'package:iron_sight/features/tournament_managment/views/tournament_management_view.dart';
// import 'package:flutter/material.dart';
// import 'package:iron_sight/Common%20Widgets/regular_CustomTextfieldForm.dart';
// import 'package:toggle_switch/toggle_switch.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:iron_sight/Common%20Widgets/image_helper.dart';
// import 'package:image_picker/image_picker.dart';



// enum UploadStatus {
//   pending,
//   success,
//   error,
//   waiting,
// }

// final loadingProvider = StateNotifierProvider<LoadingNotifier, bool>((ref) {
//   return LoadingNotifier(); // Initialize the notifier
// });

// class LoadingNotifier extends StateNotifier<bool> {
//   LoadingNotifier() : super(false); // Initialize with false

//   void setLoading(bool isLoading) {
//     state = isLoading; // Update the state
//   }
// }

// final bannerUploadProvider =
//     StateNotifierProvider<BannerUploadProviderNotifier, UploadStatus>((ref) {
//   return BannerUploadProviderNotifier(); // Initialize the notifier
// });

// class BannerUploadProviderNotifier extends StateNotifier<UploadStatus> {
//   BannerUploadProviderNotifier()
//       : super(UploadStatus.waiting); // Initialize with false

//   void setBannerLoading(UploadStatus newStatus) {
//     state = newStatus; // Update the state
//   }
// }


// final thumbnailUploadProvider =
//     StateNotifierProvider<ThumbnailUploadNotifier, UploadStatus>((ref) {
//   return ThumbnailUploadNotifier(); // Initialize the notifier
// });

// class ThumbnailUploadNotifier extends StateNotifier<UploadStatus> {
//   ThumbnailUploadNotifier()
//       : super(UploadStatus.waiting); // Initialize with false

//   void setThumbnailLoading(UploadStatus newStatus) {
//     state = newStatus; // Update the state
//   }
// }


// // Map<String, dynamic> editTournamentForm = {"Type":'Online','In_House':true};


// int firsttoggleSwitchValue = 0;
// int secondtoggleSwitchValue = 0;

// Map<String, List<String>> countryCityMap = {
//   'Saudi Arabia': [
//     'Dammam',
//     'Riyadh',
//     'Buraydah',
//   ],
//   'Bahrain': [
//     'Manama',
//     'Muharraq',
//     'Riffa',
//   ],
//   'United Arab Emirates': [
//     'Dubai',
//     'Abu Dhabi',
//     'Sharjah',
//   ],
//   'Kuwait': [
//     'Kuwait City',
//     'Al Ahmadi',
//     'Hawalli',
//   ],
//   'Qatar': [
//     'Doha',
//     'Al Rayyan',
//     'Umm Salal',
//   ],
// };

// String selectedCountry = 'Select a Country';
// String selectedCity = 'Select a City';

// class TournamentEditView extends ConsumerStatefulWidget {
//   final String tournamentId;
//   const TournamentEditView(
//     {Key? key, required this.tournamentId}) : super(key: key);

//   @override
//   ConsumerState<TournamentEditView> createState() => _TournamentEditViewState();
// }

// class _TournamentEditViewState extends ConsumerState<TournamentEditView> 
//   with SingleTickerProviderStateMixin {
//   final _formkey = GlobalKey<FormState>();

//   String? _thumbnail;
//   String? _banner;
  
//   final imageHelper = ImageHelper();
//   final ImagePicker _picker = ImagePicker();
//   late Map<String, File?> uploadFilesForm;

//   final TextEditingController _TournamentNameController = TextEditingController();
//   final TextEditingController _GameNameController = TextEditingController();
//   final TextEditingController _StartDateController = TextEditingController();
//   final TextEditingController _RegistrationController = TextEditingController();
//   final TextEditingController _StreamingController = TextEditingController();
//   final TextEditingController _PrizePoolController = TextEditingController();
//   final TextEditingController _DescriptionController = TextEditingController();

//   DateTime startDate = DateTime.now();
//   String selectedHour = '00:00';

//   int selectedNumberofParticipants = 2;
  

//   void updateDateControllers() {
//     _StartDateController.text = DateFormat('yyyy-MM-dd').format(startDate);
//   }
//   late Map<String, dynamic> editTournamentForm;
//   @override
//   void initState() {
//     super.initState();
//     _thumbnail =  ref.read(singleTournamentStateProvider).value!.thumbnail;
//     _banner = ref.read(singleTournamentStateProvider).value!.banner;
//     uploadFilesForm = {'thumbnail': null,'banner': null,};
//     editTournamentForm = {"Type":'Online','In_House':true};
//   }

//   void dispose() {
//     _TournamentNameController.dispose();
//     _GameNameController.dispose();
//     _StartDateController.dispose();
//     _RegistrationController.dispose();
//     _StreamingController.dispose();
//     _PrizePoolController.dispose();
//     _DescriptionController.dispose();
//     super.dispose();
//   }

//   Future<void> uploadImagesForm() async {
//     ref.read(loadingProvider.notifier).setLoading(true);
//     if(uploadFilesForm['Banner']!=null && uploadFilesForm['Thumbnail']!=null){
//                    ref
//           .read(bannerUploadProvider.notifier)
//           .setBannerLoading(UploadStatus.pending);
//           ref
//           .read(thumbnailUploadProvider.notifier)
//           .setThumbnailLoading(UploadStatus.pending);

//           await ref.read(singleTournamentStateProvider.notifier).uploadTournamentPictures(uploadFilesForm['Banner']!, uploadFilesForm['Thumbnail']!);

//                      ref
//           .read(bannerUploadProvider.notifier)
//           .setBannerLoading(UploadStatus.success);
//           ref
//           .read(thumbnailUploadProvider.notifier)
//           .setThumbnailLoading(UploadStatus.success);

//     }
//     else if (uploadFilesForm['Banner'] != null) {
//       try {
//           ref
//           .read(bannerUploadProvider.notifier)
//           .setBannerLoading(UploadStatus.pending);

//       await ref
//           .read(singleTournamentStateProvider.notifier)
//           .uploadTournamentBanner(uploadFilesForm['Banner']!);
//       ref
//           .read(bannerUploadProvider.notifier)
//           .setBannerLoading(UploadStatus.success);
       
//       } catch (e) {
//          ref
//             .read(bannerUploadProvider.notifier)
//             .setBannerLoading(UploadStatus.error);
      
//       }
//     }
//     else if (uploadFilesForm['Thumbnail'] != null) {
//       try {
//           ref
//           .read(thumbnailUploadProvider.notifier)
//           .setThumbnailLoading(UploadStatus.pending);

//     await ref
//           .read(singleTournamentStateProvider.notifier)
//           .uploadTournamentThumbnail(uploadFilesForm['Thumbnail']!);

      
//         ref
//             .read(thumbnailUploadProvider.notifier)
//             .setThumbnailLoading(UploadStatus.success);
//       } catch (e) {
//          ref
//             .read(thumbnailUploadProvider.notifier)
//             .setThumbnailLoading(UploadStatus.error);
//       }
//     }
//     ref.read(loadingProvider.notifier).setLoading(false);
//     if (mounted) {
//       Navigator.of(context).push(MaterialPageRoute(builder: (context) {
//       return   TournamentManagementView(tournamentId: widget.tournamentId,);
//       },));
//     }
//   }


//   @override
//   Widget build(BuildContext context) {
//     final tournamentDetails = ref.watch(singleTournamentStateProvider);

//     double screenWidth = MediaQuery.of(context).size.width;
//     final isLoading = ref.watch(loadingProvider);
//     final isThumbnailLoading = ref.watch(thumbnailUploadProvider);
//     // final isBannerLoading = ref.watch(bannerUploadProvider);


    
//     return Container(
//       decoration: const BoxDecoration(
//         image: DecorationImage(
//             image: AssetImage('assets/background.jpg'), fit: BoxFit.cover),
//       ),
//       child: DefaultTabController(
//         initialIndex: 0,
//         length: 4,
//         child: Scaffold(
//           backgroundColor: Colors.transparent,
//           appBar: AppBar(
//               backgroundColor: Colors.transparent,
//               leading: Padding(
//                 padding: const EdgeInsets.only(left: 10.0),
//                 child: Container(
//                   decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.black.withOpacity(0.6)),
//                   child: IconButton(
//                     icon: const Icon(Icons.arrow_back, color: Colors.white),
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                   ),
//                 ),
//               ),
//               flexibleSpace: Container(
//                   decoration: const BoxDecoration(
//                       image: DecorationImage(
//                 image: AssetImage('assets/IronSightLogo.png'),
//               )))),
//           body: SingleChildScrollView(
//             child: Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0),
//               child: Form(
//                 key: _formkey,
//                 child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
// /////////////////////Start of "TOURNAMENT NAME"//////////////////////////

//                     children: [
//                       const SizedBox(
//                         height: 22,
//                       ),

//                       Text('Create a New Tournament',
//                           style: Theme.of(context).textTheme.titleLarge),
//                       const SizedBox(
//                         height: 33,
//                       ),
//                       Text('Type and Location',
//                           style: Theme.of(context).textTheme.titleMedium),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8.0, vertical: 0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Type',
//                                 style: Theme.of(context).textTheme.bodyMedium),
//                             const SizedBox(
//                               height: 5,
//                             ),
//                             Material(
//                               elevation: 10,
//                               shadowColor: Colors.black,
//                               borderRadius: BorderRadius.circular(15),
//                               child: ToggleSwitch(
//                                 key: ValueKey<int>(firsttoggleSwitchValue),
//                                 initialLabelIndex: firsttoggleSwitchValue,
//                                 minWidth: 180,
//                                 cornerRadius: 15,
//                                 activeFgColor: Colors.white,
//                                 inactiveBgColor:
//                                     const Color.fromRGBO(36, 36, 36, 1),
//                                 inactiveFgColor: Colors.white,
//                                 totalSwitches: 2,
//                                 labels: const [
//                                   'IronSight Hosted',
//                                   'Third-Party Hosted'
//                                 ],
//                                 icons: const [
//                                   Icons.computer_rounded,
//                                   Icons.man_2_rounded
//                                 ],
//                                 activeBgColors: const [
//                                   [Color.fromRGBO(89, 54, 183, 1)],
//                                   [Color.fromRGBO(89, 54, 183, 1)]
//                                 ],
//                                 onToggle: (int? index) {
//                                   setState(() {
//                                     firsttoggleSwitchValue = index!;
//                                     editTournamentForm['type'] =
//                                         index == 0 ? 'Online' : 'In-Person';
//                                   });
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(
//                         height: 33,
//                       ),

//                       Text('Tournament Name',
//                           style: Theme.of(context).textTheme.titleMedium),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8.0, vertical: 0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Tournament Name',
//                                 style: Theme.of(context).textTheme.bodyMedium),
//                             const SizedBox(
//                               height: 5,
//                             ),
//                             CustomTextFormField(
//                               controller: _TournamentNameController,
//                               hintText: 'My Awesome Tournament',
//                               prefixIcon: Icons.wysiwyg,
//                               onSaved: (p0) {
//                                 editTournamentForm['tournamentName'] = p0!;
//                               },
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(
//                         height: 33,
//                       ),

// /////////////////////Start of "GAME NAME"//////////////////////////

//                       Text('Game Name',
//                           style: Theme.of(context).textTheme.titleMedium),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8.0, vertical: 0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Game Name',
//                                 style: Theme.of(context).textTheme.bodyMedium),
//                             const SizedBox(
//                               height: 5,
//                             ),
//                             CustomTextFormField(
//                               controller: _GameNameController,
//                               hintText: 'Enter Game Name',
//                               prefixIcon: Icons.wysiwyg,
//                               onSaved: (p0) {
//                                 editTournamentForm['gameName'] = p0!;
//                               },
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(
//                         height: 33,
//                       ),

// /////////////////////Start of "DATE"//////////////////////////

//                       Text('Date',
//                           style: Theme.of(context).textTheme.titleMedium),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8.0, vertical: 0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const SizedBox(
//                               height: 5,
//                             ),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text('Start Date',
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .bodyMedium),
//                                       const SizedBox(
//                                         height: 5,
//                                       ),
//                                       Material(
//                                         elevation: 10,
//                                         shadowColor: Colors.black,
//                                         borderRadius: BorderRadius.circular(15),
//                                         child: SizedBox(
//                                           width: screenWidth * 0.5,
//                                           child: TextFormField(
//                                             controller: _StartDateController,
//                                             readOnly:
//                                                 true, // to prevent the opening of the keyboard
//                                             decoration: InputDecoration(
//                                                 prefixIcon:
//                                                     const Icon(Icons.wysiwyg),
//                                                 contentPadding:
//                                                     const EdgeInsets.only(
//                                                         left: 10),
//                                                 filled: true,
//                                                 fillColor: const Color.fromRGBO(
//                                                     36, 36, 36, 1),
//                                                 hintText: ('Start Date'),
//                                                 hintStyle: const TextStyle(
//                                                     fontSize: 12,
//                                                     color: Color.fromRGBO(
//                                                         112, 112, 112, 1)),
//                                                 border: OutlineInputBorder(
//                                                   borderSide: BorderSide.none,
//                                                   borderRadius:
//                                                       BorderRadius.circular(15),
//                                                 )),
//                                             onTap: () async {
//                                               // Below line stops keyboard from appearing
//                                               FocusScope.of(context)
//                                                   .requestFocus(
//                                                       new FocusNode());

//                                               // Show Date Picker Here
//                                               showDatePicker(
//                                                 context: context,
//                                                 initialDate: startDate,
//                                                 firstDate: DateTime.now(),
//                                                 lastDate: DateTime(2100),
//                                               ).then((pickedDate) {
//                                                 if (pickedDate != null &&
//                                                     pickedDate != startDate) {
//                                                   setState(() {
//                                                     startDate = pickedDate;
//                                                     updateDateControllers();
//                                                   });
//                                                 }
//                                               });
//                                             },
//                                             validator: (value) {
//                                               if (value!.isEmpty) {
//                                                 return 'Please enter some text';
//                                               }
//                                               return null;
//                                             },
//                                             onSaved: (newValue) {
//                                               editTournamentForm[
//                                                   'startDate'] = newValue!;
//                                             },
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   width: 45,
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(
//                               height: 22,
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 0.0, vertical: 0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text('Time',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .bodyMedium),
//                                   const SizedBox(
//                                     height: 5,
//                                   ),
//                                   Material(
//                                     elevation: 10,
//                                     shadowColor: Colors.black,
//                                     borderRadius: BorderRadius.circular(15),
//                                     child: SizedBox(
//                                       width: screenWidth * 0.5,
//                                       child: DropdownButtonFormField<String>(
//                                         decoration: InputDecoration(
//                                             prefixIcon:
//                                                 const Icon(Icons.wysiwyg),
//                                             contentPadding:
//                                                 const EdgeInsets.only(left: 10),
//                                             filled: true,
//                                             fillColor: const Color.fromRGBO(
//                                                 36, 36, 36, 1),
//                                             hintText: ('Select Hour'),
//                                             hintStyle: const TextStyle(
//                                                 fontSize: 12,
//                                                 color: Color.fromRGBO(
//                                                     112, 112, 112, 1)),
//                                             border: OutlineInputBorder(
//                                               borderSide: BorderSide.none,
//                                               borderRadius:
//                                                   BorderRadius.circular(15),
//                                             )),
//                                         items: List<String>.generate(24,
//                                             (int index) {
//                                           return '${index < 10 ? '0$index' : index.toString()}:00';
//                                         }).map((String hour) {
//                                           return DropdownMenuItem<String>(
//                                             value: hour,
//                                             child: Text(hour),
//                                           );
//                                         }).toList(),
//                                         onChanged: (newValue) {
//                                           setState(() {
//                                             selectedHour = newValue!;
//                                           });
//                                         },
//                                         validator: (value) {
//                                           if (value == null || value!.isEmpty) {
//                                             return 'Please enter some text';
//                                           }
//                                           return null;
//                                         },
//                                         onSaved: (newValue) {
//                                           editTournamentForm['time'] =
//                                               newValue!;
//                                         },
//                                       ),
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(
//                         height: 33,
//                       ),
// /////////////////////Start of "TYPE AND LOCATION"//////////////////////////

//                       Text('Type and Location',
//                           style: Theme.of(context).textTheme.titleMedium),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8.0, vertical: 0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Type',
//                                 style: Theme.of(context).textTheme.bodyMedium),
//                             const SizedBox(
//                               height: 5,
//                             ),
//                             Material(
//                               elevation: 10,
//                               shadowColor: Colors.black,
//                               borderRadius: BorderRadius.circular(15),
//                               child: ToggleSwitch(
//                                 key: ValueKey<int>(secondtoggleSwitchValue),
//                                 initialLabelIndex: secondtoggleSwitchValue,
//                                 minWidth: 172.8,
//                                 cornerRadius: 15,
//                                 activeFgColor: Colors.white,
//                                 inactiveBgColor:
//                                     const Color.fromRGBO(36, 36, 36, 1),
//                                 inactiveFgColor: Colors.white,
//                                 totalSwitches: 2,
//                                 labels: const ['Online', 'In-Person'],
//                                 icons: const [
//                                   Icons.computer_rounded,
//                                   Icons.man_2_rounded
//                                 ],
//                                 activeBgColors: const [
//                                   [Color.fromRGBO(89, 54, 183, 1)],
//                                   [Color.fromRGBO(89, 54, 183, 1)]
//                                 ],
//                                 onToggle: (int? index) {
//                                   setState(() {
//                                     secondtoggleSwitchValue = index!;
//                                     editTournamentForm['type'] =
//                                         index == 0 ? 'Online' : 'In-Person';
//                                   });
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(
//                         height: 22,
//                       ),
// /////////////////////Start of "COUNTRY AND CITY"//////////////////////////
//                       if (secondtoggleSwitchValue == 1)
//                         Column(
//                           children: <Widget>[
//                             Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 8.0, vertical: 0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text('Country',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .bodyMedium),
//                                   const SizedBox(
//                                     height: 5,
//                                   ),

//                                   Material(
//                                     elevation: 10,
//                                     shadowColor: Colors.black,
//                                     borderRadius: BorderRadius.circular(15),
//                                     child: SizedBox(
//                                       width: screenWidth * 0.7,
//                                       child: DropdownButtonFormField(
//                                         value: selectedCountry,
//                                         decoration: InputDecoration(
//                                             prefixIcon:
//                                                 const Icon(Icons.wysiwyg),
//                                             contentPadding:
//                                                 const EdgeInsets.only(left: 10),
//                                             filled: true,
//                                             fillColor: const Color.fromRGBO(
//                                                 36, 36, 36, 1),
//                                             hintText: ('Country'),
//                                             hintStyle: const TextStyle(
//                                                 fontSize: 12,
//                                                 color: Color.fromRGBO(
//                                                     112, 112, 112, 1)),
//                                             border: OutlineInputBorder(
//                                               borderSide: BorderSide.none,
//                                               borderRadius:
//                                                   BorderRadius.circular(15),
//                                             )),
//                                         items: <DropdownMenuItem<String>>[
//                                           const DropdownMenuItem<String>(
//                                             value: 'Select a Country',
//                                             child: Text('Select a Country'),
//                                           ),
//                                           ...countryCityMap.keys
//                                               .map((String country) {
//                                             return DropdownMenuItem<String>(
//                                               value: country,
//                                               child: Text(country),
//                                             );
//                                           }).toList(),
//                                         ],
//                                         onChanged: (newValue) {
//                                           setState(() {
//                                             selectedCountry = newValue!;
//                                             selectedCity = 'Select a City';
//                                           });
//                                         },
//                                         validator: (value) {
//                                           if (value!.isEmpty) {
//                                             return 'Please enter some text';
//                                           }
//                                           return null;
//                                         },
//                                         onSaved: (newValue) {
//                                           editTournamentForm['country'] =
//                                               newValue!;
//                                         },
//                                       ),
//                                     ),
//                                   ),

//                                   const SizedBox(
//                                     height: 10,
//                                   ),
//                                   // Remove the unnecessary condition since selectedCountry cannot be null.
//                                   if (selectedCountry != null &&
//                                       selectedCountry != 'Select a Country')
//                                     Text('City',
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .bodyMedium),
//                                   const SizedBox(
//                                     height: 5,
//                                   ),
//                                   Material(
//                                     elevation: 10,
//                                     shadowColor: Colors.black,
//                                     borderRadius: BorderRadius.circular(15),
//                                     child: SizedBox(
//                                       width: screenWidth * 0.5,
//                                       child: DropdownButtonFormField<String>(
//                                         decoration: InputDecoration(
//                                             prefixIcon:
//                                                 const Icon(Icons.wysiwyg),
//                                             contentPadding:
//                                                 const EdgeInsets.only(left: 10),
//                                             filled: true,
//                                             fillColor: const Color.fromRGBO(
//                                                 36, 36, 36, 1),
//                                             hintText: ('City'),
//                                             hintStyle: const TextStyle(
//                                                 fontSize: 12,
//                                                 color: Color.fromRGBO(
//                                                     112, 112, 112, 1)),
//                                             border: OutlineInputBorder(
//                                               borderSide: BorderSide.none,
//                                               borderRadius:
//                                                   BorderRadius.circular(15),
//                                             )),
//                                         items: <DropdownMenuItem<String>>[
//                                           const DropdownMenuItem<String>(
//                                             value: 'Select a City',
//                                             child: Text('Select a City'),
//                                           ),
//                                           ...countryCityMap[selectedCountry]
//                                                   ?.map((String city) {
//                                                 // Added null check here
//                                                 return DropdownMenuItem<String>(
//                                                   value: city,
//                                                   child: Text(city),
//                                                 );
//                                               }).toList() ??
//                                               [], // Added null check here
//                                         ],
//                                         onChanged: (newValue) {
//                                           setState(() {
//                                             selectedCity = newValue!;
//                                           });
//                                         },
//                                         validator: (value) {
//                                           if (value!.isEmpty) {
//                                             return 'Please enter some text';
//                                           }
//                                           return null;
//                                         },
//                                         onSaved: (newValue) {
//                                           editTournamentForm['city'] =
//                                               newValue!;
//                                         },
//                                       ),
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),

//                       const SizedBox(
//                         height: 33,
//                       ),
// /////////////////////Start of "REGISTRATION LINK"//////////////////////////
//                       if (firsttoggleSwitchValue == 1)
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: <Widget>[
//                             Text('Registration Link',
//                                 style: Theme.of(context).textTheme.titleMedium),
//                             Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 8.0, vertical: 0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text('Registration Link',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .bodyMedium),
//                                   const SizedBox(
//                                     height: 5,
//                                   ),
//                                   CustomTextFormField(
//                                     controller: _RegistrationController,
//                                     hintText: 'Enter Registration Link',
//                                     prefixIcon: Icons.wysiwyg,
//                                     onSaved: (p0) {
//                                       editTournamentForm['registrationLink'] =
//                                           p0!;
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),

//                       const SizedBox(
//                         height: 33,
//                       ),
// /////////////////////Start of "STREAMING LINK"//////////////////////////
//                       Text('Streaming Link',
//                           style: Theme.of(context).textTheme.titleMedium),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8.0, vertical: 0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Streaming Link',
//                                 style: Theme.of(context).textTheme.bodyMedium),
//                             const SizedBox(
//                               height: 5,
//                             ),
//                             CustomTextFormField(
//                               controller: _StreamingController,
//                               hintText: 'Enter Streaming Link',
//                               prefixIcon: Icons.wysiwyg,
//                               onSaved: (p0) {
//                                 editTournamentForm['streamingLink'] = p0!;
//                               },
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(
//                         height: 33,
//                       ),
// /////////////////////Start of "NUM OF PARTICIPANTS"//////////////////////////
//                       Text('Number Of Participants',
//                           style: Theme.of(context).textTheme.titleMedium),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8.0, vertical: 0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Number Of Participants',
//                                 style: Theme.of(context).textTheme.bodyMedium),
//                             const SizedBox(
//                               height: 5,
//                             ),
//                             Material(
//                               elevation: 10,
//                               shadowColor: Colors.black,
//                               borderRadius: BorderRadius.circular(15),
//                               child: SizedBox(
//                                 width: screenWidth * 0.5,
//                                 child: DropdownButtonFormField<int>(
//                                   decoration: InputDecoration(
//                                       prefixIcon: const Icon(Icons.wysiwyg),
//                                       contentPadding:
//                                           const EdgeInsets.only(left: 10),
//                                       filled: true,
//                                       fillColor:
//                                           const Color.fromRGBO(36, 36, 36, 1),
//                                       hintText: ('City'),
//                                       hintStyle: const TextStyle(
//                                           fontSize: 12,
//                                           color:
//                                               Color.fromRGBO(112, 112, 112, 1)),
//                                       border: OutlineInputBorder(
//                                         borderSide: BorderSide.none,
//                                         borderRadius: BorderRadius.circular(15),
//                                       )),
//                                   value: selectedNumberofParticipants,
//                                   items: List<int>.generate(
//                                           6, (i) => pow(2, i + 1) as int)
//                                       .map((int value) {
//                                     return DropdownMenuItem<int>(
//                                       value: value,
//                                       child: Text(value.toString()),
//                                     );
//                                   }).toList(),
//                                   onChanged: (int? newValue) {
//                                     setState(() {
//                                       selectedNumberofParticipants = newValue!;
//                                     });
//                                   },
//                                   validator: (value) {
//                                     // check if its of power 2 or not
//                                     if (value!.isNegative ||
//                                         value == 0 ||
//                                         (value & (value - 1)) != 0) {
//                                       return 'Please enter a valid number';
//                                     }
//                                   },
//                                   onSaved: (newValue) {
//                                     editTournamentForm['max_Participants'] =
//                                         newValue.toString();
//                                   },
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                       ),

//                       const SizedBox(
//                         height: 33,
//                       ),
// /////////////////////Start of "PRIZE POOL"//////////////////////////
//                       Text('Prize Pool',
//                           style: Theme.of(context).textTheme.titleMedium),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8.0, vertical: 0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Prize Pool',
//                                 style: Theme.of(context).textTheme.bodyMedium),
//                             const SizedBox(
//                               height: 5,
//                             ),
//                             Material(
//                               elevation: 10,
//                               shadowColor: Colors.black,
//                               borderRadius: BorderRadius.circular(15),
//                               child: SizedBox(
//                                 width: screenWidth * 0.5,
//                                 child: TextFormField(
//                                   keyboardType: TextInputType.number,
//                                   controller: _PrizePoolController,
//                                   decoration: InputDecoration(
//                                     prefixIcon: const Icon(Icons.wysiwyg),
//                                     contentPadding:
//                                         const EdgeInsets.only(left: 10),
//                                     filled: true,
//                                     fillColor:
//                                         const Color.fromRGBO(36, 36, 36, 1),
//                                     hintText: "Prize Pool amount",
//                                     hintStyle: const TextStyle(
//                                       fontSize: 12,
//                                       color: Color.fromRGBO(112, 112, 112, 1),
//                                     ),
//                                     border: OutlineInputBorder(
//                                       borderSide: BorderSide.none,
//                                       borderRadius: BorderRadius.circular(15),
//                                     ),
//                                   ),
//                                   validator: (value) {
//                                     if (value!.isEmpty) {
//                                       return 'Please enter some text';
//                                     }
//                                     return null;
//                                   },
//                                   onSaved: (newValue) {
//                                     editTournamentForm['prizePool'] =
//                                         newValue!;
//                                   },
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                       ),

//                       const SizedBox(
//                         height: 33,
//                       ),
// /////////////////////Start of "DESCRIPTION"//////////////////////////
//                       Text('Description',
//                           style: Theme.of(context).textTheme.titleMedium),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8.0, vertical: 0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Description',
//                                 style: Theme.of(context).textTheme.bodyMedium),
//                             const SizedBox(
//                               height: 5,
//                             ),
//                             Material(
//                               elevation: 10,
//                               shadowColor: Colors.black,
//                               borderRadius: BorderRadius.circular(15),
//                               child: SizedBox(
//                                 width: screenWidth * 0.5,
//                                 child: TextFormField(
//                                   decoration: InputDecoration(
//                                       prefixIcon: const Icon(Icons.wysiwyg),
//                                       contentPadding: const EdgeInsets.only(
//                                           left: 10, top: 30, bottom: 30),
//                                       filled: true,
//                                       fillColor:
//                                           const Color.fromRGBO(36, 36, 36, 1),
//                                       hintText:
//                                           ('lorem ipsum dolor sit amet, consectetur .'),
//                                       hintStyle: const TextStyle(
//                                           fontSize: 12,
//                                           color:
//                                               Color.fromRGBO(112, 112, 112, 1)),
//                                       border: OutlineInputBorder(
//                                         borderSide: BorderSide.none,
//                                         borderRadius: BorderRadius.circular(15),
//                                       )),
//                                   validator: (value) {
//                                     if (value!.isEmpty) {
//                                       return 'Please enter some text';
//                                     }
//                                     return null;
//                                   },
//                                   onSaved: (newValue) {
//                                     editTournamentForm['Description'] =
//                                         newValue!;
//                                   },
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(
//                               height: 33,
//                             ),
//                           ],
//                         ),
//                       ),
//                       ElevatedButton(
//                         child: const Text('Submit'),
//                         onPressed: () async {
//                           //
//                           if (_formkey.currentState!.validate()) {
//                             // await _formkey.currentState!!.save();
//                             // print(editTournamentForm);
//                             // final response = await ref
//                             //     .read(tournamentStateProvider.notifier)
//                             //     .createTournament(editTournamentForm);

//                             ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(content: Text('tour id is ')));
//                             // Navigator.push(
//                             //   context,
//                             //   MaterialPageRoute(
//                             //       builder: (context) =>
//                             //           TournamentManagmentView()),
//                             // );
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                     content: Text(
//                                         'There are some fields that are incorrect. Please check them')));
//                           }
//                         },
//                       ),
//                     ]),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
