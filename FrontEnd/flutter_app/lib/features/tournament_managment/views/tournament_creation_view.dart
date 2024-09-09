import 'dart:math';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/features/tournament_managment/controller/tournament_provider.dart';
import 'package:iron_sight/features/tournament_managment/views/tournament_creation_view2.dart';
import "package:iron_sight/features/tournament_managment/views/tournament_management_view.dart";
import 'package:flutter/material.dart';
import 'package:iron_sight/Common%20Widgets/regular_CustomTextfieldForm.dart';
import 'package:iron_sight/features/tournament_managment/widgets/game_search.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _formkey = GlobalKey<FormState>();

String selectedHour = '00:00';
int selectedNumberofParticipants = 2;
DateTime startDate = DateTime.now();
DateTime endDate = DateTime.now();

// {type: In-Person, Tournament_Org: IronSight, tournamentName: tName, gameName: gName, startDate: 2024-02-13, time: 09:00, registrationLink: svcvsc, streamingLink: cscscsc,
//  max_Participants: 2, prizePool: 5,
//   Description: ddff, country: Bahrain,
//    city: Manama}
final loadingProvider = StateNotifierProvider<LoadingNotifier, bool>((ref) {
  return LoadingNotifier(); // Initialize the notifier
});

class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false); // Initialize with false

  void setLoading(bool isLoading) {
    state = isLoading; // Update the state
  }
}

int firsttoggleSwitchValue = 0;
int secondtoggleSwitchValue = 0;

Map<String, List<String>> countryCityMap = {
  'Saudi Arabia': [
    'Dammam',
    'Riyadh',
    'Buraydah',
  ],
  'Bahrain': [
    'Manama',
    'Muharraq',
    'Riffa',
  ],
  'UAE': [
    'Dubai',
    'Abu Dhabi',
    'Sharjah',
  ],
  'Kuwait': [
    'Kuwait City',
    'Al Ahmadi',
    'Hawalli',
  ],
  'Qatar': [
    'Doha',
    'Al Rayyan',
    'Umm Salal',
  ],
};

class TournamentCreationView extends ConsumerStatefulWidget {
  const TournamentCreationView({super.key});

  @override
  ConsumerState<TournamentCreationView> createState() =>
      _TournamentCreationViewState();
}

class _TournamentCreationViewState
    extends ConsumerState<TournamentCreationView> {
  late TextEditingController _TournamentNameController =
      TextEditingController();
  late TextEditingController _GameNameController = TextEditingController();
  late TextEditingController _StartDateController = TextEditingController();
  late TextEditingController _TypeController = TextEditingController();
  late TextEditingController _CountryController = TextEditingController();
  late TextEditingController _CityController = TextEditingController();
  late TextEditingController _RegistrationController = TextEditingController();
  late TextEditingController _StreamingController = TextEditingController();
  late TextEditingController _NumberOfParticipantsController =
      TextEditingController();
  late TextEditingController _PrizePoolController = TextEditingController();
  late TextEditingController _DescriptionController = TextEditingController();

  String selectedCountry = 'Select a Country';
  String selectedCity = 'Select a City';
  Map<String, dynamic> createTournamentForm = {"Type":'Online','In_House':true};
  void updateDateControllers() {
    DateTime startDateUtcPlus3 = startDate.toUtc().add(const Duration(hours: 3));
  _StartDateController.text = DateFormat('yyyy-MM-dd').format(startDateUtcPlus3);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _TournamentNameController = TextEditingController();
    _GameNameController = TextEditingController();
    _StartDateController = TextEditingController();
    _TypeController = TextEditingController();
    _CountryController = TextEditingController();
    _CityController = TextEditingController();
    _RegistrationController = TextEditingController();
    _StreamingController = TextEditingController();
    _NumberOfParticipantsController = TextEditingController();
    _PrizePoolController = TextEditingController();
    _DescriptionController = TextEditingController();

    // createTournamentForm = {
    //   //take the variables from the provider
    //   'Type': ref.read(tournamentStateProvider.notifier).state!.type,
    //   'Tournament_Org':
    //       ref.read(tournamentStateProvider.notifier).state!.tournamentOrg,
    //   'Description':
    //       ref.read(tournamentStateProvider.notifier).state!.description,
    //   "Country": ref.read(tournamentStateProvider.notifier).state!.country,
    //   "City": ref.read(tournamentStateProvider.notifier).state!.city,
    //   'Max_Participants':
    //       ref.read(tournamentStateProvider.notifier).state!.maxParticipants,
    //   // remove the word 'SAR' from the prize pool

    //   'Prize_Pool': ref
    //       .read(tournamentStateProvider.notifier)
    //       .state!
    //       .prizePool
    //       .replaceAll('SAR', '')
    //       .replaceAll(' ', ''),
    //   'Streaming_Link':
    //       ref.read(tournamentStateProvider.notifier).state!.streamingLink,
    //   'Registration_Link':
    //       ref.read(tournamentStateProvider.notifier).state!.registrationLink,
    //   'Time': ref.read(tournamentStateProvider.notifier).state!.time,
    //   'Date': ref.read(tournamentStateProvider.notifier).state!.date,
    //   'Tournament_Name':
    //       ref.read(tournamentStateProvider.notifier).state!.tournamentName,
    //   'Game_Name':
    //       ref.read(tournamentStateProvider.notifier).state!.tournamentGame,
    //   'In_House': ref.read(tournamentStateProvider.notifier).state!.In_House,
    // };
    // _TournamentNameController.text =
    //     ref.read(tournamentStateProvider.notifier).state!.tournamentName;
    // _GameNameController.text =
    //     ref.read(tournamentStateProvider.notifier).state!.tournamentGame;
    // _StartDateController.text =
    //     ref.read(tournamentStateProvider.notifier).state!.date;
    // selectedHour = ref.read(tournamentStateProvider.notifier).state!.time;
    // _TypeController.text =
    //     ref.read(tournamentStateProvider.notifier).state!.type;
    // _CountryController.text =
    //     ref.read(tournamentStateProvider.notifier).state!.country;
    // _CityController.text =
    //     ref.read(tournamentStateProvider.notifier).state!.city;
    // ;
    // _RegistrationController.text =
    //     ref.read(tournamentStateProvider.notifier).state!.registrationLink;
    // _StreamingController.text =
    //     ref.read(tournamentStateProvider.notifier).state!.streamingLink;
    // selectedNumberofParticipants =
    //     ref.read(tournamentStateProvider.notifier).state!.maxParticipants;
    // _PrizePoolController.text = ref
    //     .read(tournamentStateProvider.notifier)
    //     .state!
    //     .prizePool
    //     .replaceAll('SAR', '')
    //     .replaceAll(' ', '');
    // _DescriptionController.text =
    //     ref.read(tournamentStateProvider.notifier).state!.description;
    // if (!ref.read(tournamentStateProvider.notifier).state!.In_House) {
    //   firsttoggleSwitchValue = 1;
    // }
    // if (ref.read(tournamentStateProvider.notifier).state!.type ==
    //     'In-Person') {
    //   secondtoggleSwitchValue = 1;
    // } else {
    //   print('the state is null');
    //   createTournamentForm = {
    //     'Type': 'Online',
    //     'Tournament_Org': 'IronSight',
    //     'Results': "Empty List",
    //   };
    // }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _TournamentNameController.dispose();
    _GameNameController.dispose();
    _StartDateController.dispose();
    _TypeController.dispose();
    _CountryController.dispose();
    _CityController.dispose();
    _RegistrationController.dispose();
    _StreamingController.dispose();
    _NumberOfParticipantsController.dispose();
    _PrizePoolController.dispose();
    _DescriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final isLoading = ref.watch(loadingProvider);
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
              padding: EdgeInsets.only(top: 22.0), // Adjust the value as needed
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0),
              child: Form(
                key: _formkey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    /////////////////////Start of "TOURNAMENT NAME"//////////////////////////

                    children: [
                      const SizedBox(
                        height: 22,
                      ),

                      Text('Create a New Tournament',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(
                        height: 33,
                      ),

                      Text('Hosted By',
                          style: Theme.of(context).textTheme.titleMedium),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hosted by',
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(
                              height: 5,
                            ),
                            Material(
                              elevation: 10,
                              shadowColor: Colors.black,
                              borderRadius: BorderRadius.circular(15),
                              child: ToggleSwitch(
                                key: ValueKey<int>(firsttoggleSwitchValue),
                                initialLabelIndex: firsttoggleSwitchValue,
                                minWidth: screenWidth * 0.4,
                                cornerRadius: 15,
                                activeFgColor: Colors.white,
                                inactiveBgColor:
                                    const Color.fromRGBO(36, 36, 36, 1),
                                inactiveFgColor: Colors.white,
                                totalSwitches: 2,
                                labels: const ['IronSight', 'Third-Party'],
                                icons: const [
                                  Icons.computer_rounded,
                                  Icons.man_2_rounded
                                ],
                                activeBgColors: const [
                                  [Color.fromRGBO(89, 54, 183, 1)],
                                  [Color.fromRGBO(89, 54, 183, 1)]
                                ],
                                onToggle: (int? index) {
                                  setState(() {
                                    firsttoggleSwitchValue = index!;
                                    createTournamentForm['Type'] =
                                        index == 0 ? 'Online' : 'In-Person';
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 33,
                      ),

                      Text('Tournament Name',
                          style: Theme.of(context).textTheme.titleMedium),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tournament Name',
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(
                              height: 5,
                            ),
                            CustomTextFormField(
                              controller: _TournamentNameController,
                              hintText: 'My Awesome Tournament',
                              prefixIcon: Icons.wysiwyg,
                              onSaved: (p0) {
                                createTournamentForm['Tournament_Name'] = p0!;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 33,
                      ),

/////////////////////Start of "GAME NAME"//////////////////////////
///                     
                      GameSearchField(onGameSelected: (game) {
                        createTournamentForm['Game_Name'] = game.gameName;
                      },),
                      // Text('Game Name',
                      //     style: Theme.of(context).textTheme.titleMedium),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 8.0, vertical: 0),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Text('Game Name',
                      //           style: Theme.of(context).textTheme.bodyMedium),
                      //       const SizedBox(
                      //         height: 5,
                      //       ),
                      //       CustomTextFormField(
                      //         controller: _GameNameController,
                      //         hintText: 'Enter Game Name',
                      //         prefixIcon: Icons.wysiwyg,
                      //         onSaved: (p0) {
                      //           createTournamentForm['Game_Name'] = p0!;
                      //         },
                      //       ),
                      //     ],
                      //   ),
                      // ),

                      const SizedBox(
                        height: 33,
                      ),

/////////////////////Start of "DATE"//////////////////////////

                      Text('Date',
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
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Start Date',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Material(
                                        elevation: 10,
                                        shadowColor: Colors.black,
                                        borderRadius: BorderRadius.circular(15),
                                        child: SizedBox(
                                          width: screenWidth * 0.6,
                                          child: TextFormField(
                                            controller: _StartDateController,
                                            readOnly:
                                                true, // to prevent the opening of the keyboard
                                            decoration: InputDecoration(
                                                prefixIcon:
                                                    const Icon(Icons.wysiwyg),
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        left: 10),
                                                filled: true,
                                                fillColor: const Color.fromRGBO(
                                                    36, 36, 36, 1),
                                                hintText: ('Start Date'),
                                                hintStyle: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color.fromRGBO(
                                                        112, 112, 112, 1)),
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                )),
                                            onTap: () async {
                                              // Below line stops keyboard from appearing
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      new FocusNode());

                                              // Show Date Picker Here
                                              showDatePicker(
                                                context: context,
                                                initialDate: startDate,
                                                firstDate: DateTime.now(),
                                                lastDate: DateTime(2100),
                                              ).then((pickedDate) {
                                                if (pickedDate != null &&
                                                    pickedDate != startDate) {
                                                  setState(() {
                                                    startDate = pickedDate;
                                                    if (pickedDate
                                                        .isAfter(endDate)) {
                                                      endDate = pickedDate;
                                                      updateDateControllers();
                                                      // If the new start date is after the end date, update the end date
                                                    }
                                                    updateDateControllers();
                                                  });
                                                }
                                              });
                                            },
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Please enter some text';
                                              }
                                              return null;
                                            },
                                            onSaved: (newValue) {
                                              createTournamentForm['Date'] =
                                                  newValue!;
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 45,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 22,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0.0, vertical: 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Time',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Material(
                                    elevation: 10,
                                    shadowColor: Colors.black,
                                    borderRadius: BorderRadius.circular(15),
                                    child: SizedBox(
                                      width: screenWidth * 0.6,
                                      child: DropdownButtonFormField<String>(
                                        value: selectedHour,
                                        decoration: InputDecoration(
                                            prefixIcon:
                                                const Icon(Icons.wysiwyg),
                                            contentPadding:
                                                const EdgeInsets.only(left: 10),
                                            filled: true,
                                            fillColor: const Color.fromRGBO(
                                                36, 36, 36, 1),
                                            hintText: ('Select Hour'),
                                            hintStyle: const TextStyle(
                                                fontSize: 12,
                                                color: Color.fromRGBO(
                                                    112, 112, 112, 1)),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            )),
                                        items: List<String>.generate(24,
                                            (int index) {
                                          return '${index < 10 ? '0$index' : index.toString()}:00';
                                        }).map((String hour) {
                                          return DropdownMenuItem<String>(
                                            value: hour,
                                            child: Text(hour),
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedHour = newValue!;
                                          });
                                        },
                                        validator: (value) {
                                          if (value == null || value!.isEmpty) {
                                            return 'Please enter some text';
                                          }
                                          return null;
                                        },
                                        onSaved: (newValue) {
                                          createTournamentForm['Time'] =
                                              newValue!;
                                        },
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 33,
                      ),
/////////////////////Start of "TYPE AND LOCATION"//////////////////////////

                      Text('Type and Location',
                          style: Theme.of(context).textTheme.titleMedium),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Type',
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(
                              height: 5,
                            ),
                            Material(
                              elevation: 10,
                              shadowColor: Colors.black,
                              borderRadius: BorderRadius.circular(15),
                              child: ToggleSwitch(
                                key: ValueKey<int>(secondtoggleSwitchValue),
                                initialLabelIndex: secondtoggleSwitchValue,
                                minWidth: screenWidth * 0.4,
                                cornerRadius: 15,
                                activeFgColor: Colors.white,
                                inactiveBgColor:
                                    const Color.fromRGBO(36, 36, 36, 1),
                                inactiveFgColor: Colors.white,
                                totalSwitches: 2,
                                labels: const ['Online', 'In-Person'],
                                icons: const [
                                  Icons.computer_rounded,
                                  Icons.man_2_rounded
                                ],
                                activeBgColors: const [
                                  [Color.fromRGBO(89, 54, 183, 1)],
                                  [Color.fromRGBO(89, 54, 183, 1)]
                                ],
                                onToggle: (int? index) {
                                  setState(() {
                                    secondtoggleSwitchValue = index!;
                                    createTournamentForm['Type'] =
                                        index == 0 ? 'Online' : 'In-Person';
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 22,
                      ),
/////////////////////Start of "COUNTRY AND CITY"//////////////////////////
                      if (secondtoggleSwitchValue == 1)
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Country',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                  const SizedBox(
                                    height: 5,
                                  ),

                                  Material(
                                    elevation: 10,
                                    shadowColor: Colors.black,
                                    borderRadius: BorderRadius.circular(15),
                                    child: SizedBox(
                                      width: screenWidth * 0.6,
                                      child: DropdownButtonFormField(
                                        decoration: InputDecoration(
                                            prefixIcon:
                                                const Icon(Icons.wysiwyg),
                                            contentPadding:
                                                const EdgeInsets.only(left: 10),
                                            filled: true,
                                            fillColor: const Color.fromRGBO(
                                                36, 36, 36, 1),
                                            hintText: ('Country'),
                                            hintStyle: const TextStyle(
                                                fontSize: 12,
                                                color: Color.fromRGBO(
                                                    112, 112, 112, 1)),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            )),
                                        items: <DropdownMenuItem<String>>[
                                          ...countryCityMap.keys
                                              .map((String country) {
                                            return DropdownMenuItem<String>(
                                              value: country,
                                              child: Text(country),
                                            );
                                          }).toList(),
                                        ],
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedCountry = newValue!;
                                            selectedCity = 'Select a City';
                                          });
                                        },
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter some text';
                                          }
                                          return null;
                                        },
                                        onSaved: (newValue) {
                                          createTournamentForm['Country'] =
                                              newValue!;
                                        },
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 10,
                                  ),
                                  // Remove the unnecessary condition since selectedCountry cannot be null.
                                  if (selectedCountry != null &&
                                      selectedCountry != 'Select a Country')
                                    Text('City',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Material(
                                    elevation: 10,
                                    shadowColor: Colors.black,
                                    borderRadius: BorderRadius.circular(15),
                                    child: SizedBox(
                                      width: screenWidth * 0.5,
                                      child: DropdownButtonFormField<String>(
                                        decoration: InputDecoration(
                                            prefixIcon:
                                                const Icon(Icons.wysiwyg),
                                            contentPadding:
                                                const EdgeInsets.only(left: 10),
                                            filled: true,
                                            fillColor: const Color.fromRGBO(
                                                36, 36, 36, 1),
                                            hintText: ('City'),
                                            hintStyle: const TextStyle(
                                                fontSize: 12,
                                                color: Color.fromRGBO(
                                                    112, 112, 112, 1)),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            )),
                                        items: <DropdownMenuItem<String>>[
                                          ...countryCityMap[selectedCountry]
                                                  ?.map((String city) {
                                                // Added null check here
                                                return DropdownMenuItem<String>(
                                                  value: city,
                                                  child: Text(city),
                                                );
                                              }).toList() ??
                                              [], // Added null check here
                                        ],
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedCity = newValue!;
                                          });
                                        },
                                        validator: (value) {
                                          if (value!.isEmpty || value == null) {
                                            return 'Please enter some text';
                                          }
                                          return null;
                                        },
                                        onSaved: (newValue) {
                                          createTournamentForm['City'] =
                                              newValue!;
                                        },
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(
                        height: 33,
                      ),
/////////////////////Start of "REGISTRATION LINK"//////////////////////////
                      if (firsttoggleSwitchValue == 1)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Registration Link',
                                style: Theme.of(context).textTheme.titleMedium),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Registration Link',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  CustomTextFormField(
                                    controller: _RegistrationController,
                                    hintText: 'Enter Registration Link',
                                    prefixIcon: Icons.wysiwyg,
                                    onSaved: (p0) {
                                      createTournamentForm['Registration_Link'] =
                                          p0!;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(
                        height: 33,
                      ),
/////////////////////Start of "STREAMING LINK"//////////////////////////
                      Text('Streaming Link',
                          style: Theme.of(context).textTheme.titleMedium),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Streaming Link',
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(
                              height: 5,
                            ),
                            CustomTextFormField(
                              controller: _StreamingController,
                              hintText: 'Enter Streaming Link',
                              prefixIcon: Icons.wysiwyg,
                              onSaved: (p0) {
                                createTournamentForm['Registration_Link'] = p0!;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 33,
                      ),
/////////////////////Start of "NUM OF PARTICIPANTS"//////////////////////////
                      Text('Number Of Participants',
                          style: Theme.of(context).textTheme.titleMedium),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Number Of Participants',
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(
                              height: 5,
                            ),
                            Material(
                              elevation: 10,
                              shadowColor: Colors.black,
                              borderRadius: BorderRadius.circular(15),
                              child: SizedBox(
                                width: screenWidth * 0.6,
                                child: DropdownButtonFormField<int>(
                                  decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.wysiwyg),
                                      contentPadding:
                                          const EdgeInsets.only(left: 10),
                                      filled: true,
                                      fillColor:
                                          const Color.fromRGBO(36, 36, 36, 1),
                                      hintText: ('City'),
                                      hintStyle: const TextStyle(
                                          fontSize: 12,
                                          color:
                                              Color.fromRGBO(112, 112, 112, 1)),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(15),
                                      )),
                                  value: selectedNumberofParticipants,
                                  items: List<int>.generate(
                                          6, (i) => pow(2, i + 1) as int)
                                      .map((int value) {
                                    return DropdownMenuItem<int>(
                                      value: value,
                                      child: Text(value.toString()),
                                    );
                                  }).toList(),
                                  onChanged: (int? newValue) {
                                    setState(() {
                                      selectedNumberofParticipants = newValue!;
                                    });
                                  },
                                  validator: (value) {
                                    // check if its of power 2 or not
                                    if (value!.isNegative ||
                                        value == 0 ||
                                        (value & (value - 1)) != 0) {
                                      return 'Please enter a valid number';
                                    }
                                  },
                                  onSaved: (newValue) {
                                    createTournamentForm['Max_Participants'] =
                                        newValue.toString();
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 33,
                      ),
/////////////////////Start of "PRIZE POOL"//////////////////////////
                      Text('Prize Pool',
                          style: Theme.of(context).textTheme.titleMedium),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Prize Pool',
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(
                              height: 5,
                            ),
                            Material(
                              elevation: 10,
                              shadowColor: Colors.black,
                              borderRadius: BorderRadius.circular(15),
                              child: SizedBox(
                                width: screenWidth * 0.6,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: _PrizePoolController,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.wysiwyg),
                                    contentPadding:
                                        const EdgeInsets.only(left: 10),
                                    filled: true,
                                    fillColor:
                                        const Color.fromRGBO(36, 36, 36, 1),
                                    hintText: "Prize Pool amount",
                                    hintStyle: const TextStyle(
                                      fontSize: 12,
                                      color: Color.fromRGBO(112, 112, 112, 1),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter some text';
                                    } else if (value
                                        .contains(RegExp(r'[a-zA-Z]'))) {
                                      return 'Please enter a valid number';
                                    }
                                    return null;
                                  },
                                  onSaved: (newValue) {
                                    createTournamentForm['Prize_Pool'] =
                                        newValue!;
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 33,
                      ),
/////////////////////Start of "DESCRIPTION"//////////////////////////
                      Text('Description',
                          style: Theme.of(context).textTheme.titleMedium),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Description',
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(
                              height: 5,
                            ),
                            Material(
                              elevation: 10,
                              shadowColor: Colors.black,
                              borderRadius: BorderRadius.circular(15),
                              child: SizedBox(
                                width: screenWidth * 1,
                                child: TextFormField(
                                  maxLines: null,
                                  decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.wysiwyg),
                                      contentPadding: const EdgeInsets.only(
                                          left: 10, top: 30, bottom: 30),
                                      filled: true,
                                      fillColor:
                                          const Color.fromRGBO(36, 36, 36, 1),
                                      hintText: ('Rules, notes and comments'),
                                      hintStyle: const TextStyle(
                                          fontSize: 12,
                                          color:
                                              Color.fromRGBO(112, 112, 112, 1)),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(15),
                                      )),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    if (value.length > 255) {
                                      return 'The length should not exceed 255 characters';
                                    }
                                    return null;
                                  },
                                  onSaved: (newValue) {
                                    createTournamentForm['Description'] =
                                        newValue!;
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 33,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 20.0), // Adjust the value as needed
                        child: Center(
                          child: ElevatedButton(
                            onPressed: 
                            // isLoading
                            //     ? null
                            //     : 
                                () async {
                                    if (_formkey.currentState!.validate()) {
                                      _formkey.currentState!.save();
                                      ref
                                          .read(loadingProvider.notifier)
                                          .setLoading(true);

                                      try {
                                        await ref
                                            .read(singleTournamentStateProvider
                                                .notifier)
                                            .createTournament(
                                                createTournamentForm);
                                        ref
                                            .read(loadingProvider.notifier)
                                            .setLoading(false);
                                        String tourId= ref.read(singleTournamentStateProvider.notifier).getTournamentId();
                                        NavigatorState cntxt = Navigator.of(context);
                                        cntxt.pop();
                                        cntxt.push(MaterialPageRoute(builder: (context) {
                                          return  TournamentCreationView2(tournamentId: tourId,);
                                        },));
                                      } catch (e) {
                                        ref
                                            .read(loadingProvider.notifier)
                                            .setLoading(false);
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(e.toString()),
                                            duration:
                                                const Duration(seconds: 2),
                                          ));
                                        }
                                      }
                                    }
                                  },
                            child: isLoading
                                ? const CustomProgressIndicator()
                                : const Text('Submit'),
                          ),
                        ),
                      )
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
