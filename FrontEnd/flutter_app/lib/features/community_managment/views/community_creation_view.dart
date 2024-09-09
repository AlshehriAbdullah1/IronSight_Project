import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/Common%20Widgets/popUpScreen.dart';
import 'package:iron_sight/features/community_managment/controller/community_provider.dart';
import 'package:iron_sight/features/community_managment/views/community_creation_view_2.dart';
import 'package:iron_sight/Common%20Widgets/regular_CustomTextfieldForm.dart';
import 'package:iron_sight/models/community.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//create loading provider using riverpod that will show CircularProgressIndicator if it is in creating progress

final loadingProvider = StateNotifierProvider.autoDispose<LoadingNotifier, bool>((ref) {
  return LoadingNotifier(); // Initialize the notifier
});

class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false); // Initialize with false

  void setLoading(bool isLoading) {
    state = isLoading; // Update the state
  }
}



final selectedCommunityTypeProvider = StateNotifierProvider.autoDispose<CommunityTypeNotifier, CommunityType>((ref) {
  return CommunityTypeNotifier();
});

enum CommunityType {
  private,
  public,
}

class CommunityTypeNotifier extends StateNotifier<CommunityType> {
  CommunityTypeNotifier() : super(CommunityType.public);

  void setCommunityType(CommunityType type) {
    state = type;
  }
}

final _formkey = GlobalKey<FormState>();

// int firsttoggleSwitchValue = 0;
// int secondtoggleSwitchValue = 0;

class CommunityCreationView extends ConsumerStatefulWidget {
  const CommunityCreationView({super.key});

  // int get firsttoggleSwitchValue => firsttoggleSwitchValue;

  @override
  ConsumerState<CommunityCreationView> createState() => 
    _CommunityCreationViewState();
}

class _CommunityCreationViewState extends ConsumerState<CommunityCreationView> {
  late TextEditingController _CommunityPasswordController  ;
late TextEditingController   _CommunityNameController    ;
late TextEditingController   _CommunityDescriptionController;
late TextEditingController   _CommunityGenreController    ;

  late Map<String, dynamic> createCommunityForm;

  @override
  void initState(){
    super.initState();
    createCommunityForm = {
      'isPrivate': false
    };
     _CommunityPasswordController = TextEditingController();
 _CommunityNameController = TextEditingController();
 _CommunityDescriptionController = TextEditingController();
 _CommunityGenreController = TextEditingController();
    }
  
  @override
  void dispose(){
    super.dispose();
    _CommunityNameController.dispose();
    _CommunityDescriptionController.dispose();
    _CommunityGenreController.dispose();
    _CommunityPasswordController.dispose();
    
  }

  Future<void> createCommunity()async{ 
    
    final community = await ref.read(singleCommunityStateProvider.notifier).createCommunity(createCommunityForm);
    if(community !=null){
      // naviage to second page

      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return const CommunityCreationView2();
      },));
    }
    else{
      Platform.isIOS? showCupertinoDialog(context: context, builder: (context) {
        // pop up error message
        return CupertinoAlertDialog(
          title:const  Text("Error"),
          content:const  Text("Could not create community"),
          actions: <Widget>[
            CupertinoDialogAction(
              child:const  Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },):null;

      Platform.isAndroid ? showDialog(
        context: context,
        builder: (context) {
          // pop up error message
          return AlertDialog(
            title:const  Text("Error"),
            content:const  Text("Could not create community"),
            actions: <Widget>[
              TextButton(
                child:const Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      ) : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading= ref.watch(loadingProvider);
    double screenWidth = MediaQuery.of(context).size.width;
    final communityTypeState= ref.watch(selectedCommunityTypeProvider);
    // final communityTypeState= communityType.state;
    



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
                  children: [
                    const SizedBox(
                        height: 22,
                      ),
                      Text(
                      
                               'Create a New Community',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(
                        height: 33,
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
                               key: ValueKey<CommunityType>(communityTypeState),
                                initialLabelIndex: communityTypeState==CommunityType.private?1:0,
                                minWidth: screenWidth * 0.4,
                                cornerRadius: 15,
                                activeFgColor: Colors.white,
                                inactiveBgColor:
                                    const Color.fromRGBO(36, 36, 36, 1),
                                inactiveFgColor: Colors.white,
                                totalSwitches: 2,
                                labels: const ['Public', 'Private'],
                                icons: const [
                                  Icons.lock_open,
                                  Icons.lock
                                ],
                                activeBgColors: const [
                                  [Color.fromRGBO(89, 54, 183, 1)],
                                  [Color.fromRGBO(89, 54, 183, 1)]
                                ],
                                
                                onToggle: (int? index) {
                                     
                                         ref.read(selectedCommunityTypeProvider.notifier)
                                         .setCommunityType(index == 0 ? CommunityType.public : CommunityType.private);

                                    // print('$index is the index and we are chaning the type to ${(index == 0 ? CommunityType.public : CommunityType.private).toString()} \n\n\n this logic should result to form with ${(communityTypeState== CommunityType.private ? 'Private' : 'Public')}');
                                 

                                    // createCommunityForm= {};
                                    // print(
                                    //   'selected community type is ${communityTypeState.toString()}'
                                    // );
                                    // createCommunityForm['Type'] =
                                    //     communityTypeState== CommunityType.private ? 'Private' : 'Public';
                                    WidgetsBinding.instance!.addPostFrameCallback((_) {
    // print('$index is the index and we are changing the type to ${(index == 0 ? CommunityType.public : CommunityType.private).toString()} \n\n\n this logic should result to form with ${(communityTypeState== CommunityType.private ? 'Private' : 'Public')}');

    createCommunityForm= {};
    createCommunityForm['isPrivate'] = ref.read(selectedCommunityTypeProvider.notifier).state== CommunityType.private ? true : false;
  });
                                 
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                        if (communityTypeState== CommunityType.private )
                        const SizedBox(
                          height: 33,
                        ),
        

                      if (communityTypeState== CommunityType.private)
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
                                  Text('Password',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  CustomTextFormField(
                                    controller: _CommunityPasswordController,
                                    hintText: 'Enter a password for your community',
                                    prefixIcon: Icons.password,
                                    obscureText: true,
                                    validator: (p0) {
                                      if(p0.length < 4){
                                        return 'The password must be at least 4 characters';
                                      }
                                      if(p0.length > 30){
                                        return 'The password must not be more than 30 characters';
                                      }
                                    },
                                    onSaved: (p0) {
                                      createCommunityForm['Password'] =
                                          p0;
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


                      Text('Community Name',
                          style: Theme.of(context).textTheme.titleMedium),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Community Name',
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(
                              height: 5,
                            ),
                            CustomTextFormField(
                              controller: _CommunityNameController,
                              hintText: 'My Awesome Community',
                              prefixIcon: Icons.wysiwyg,
                              validator: (p0) {
                                if(p0.length< 3){
                                  return 'Community name is too short';
                                }
                                if(p0.length > 60){
                                  return 'Community name is too long';
                                }
                              },
                              onSaved: (p0) {
                                createCommunityForm['Community_Name'] = p0!;
                              },
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
                            Text('Community Tag',
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(
                              height: 5,
                            ),
                            CustomTextFormField(
                              controller: _CommunityGenreController,
                              hintText: '#AwesomeCommunity',
                              prefixIcon: Icons.category,
                                 validator: (p0) {
                                if(p0.length< 3){
                                  return 'Community Tag is too short';
                                }
                                if(p0.length > 20){
                                  return 'Community Tag is too long';
                                }
                              },
                              onSaved: (p0) {
                                createCommunityForm['Community_Tag'] = p0!;
                              },
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
                            Text('Community Description',
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(
                              height: 5,
                            ),
                            CustomTextFormField(
                              controller: _CommunityDescriptionController,
                              hintText: 'A brief description of your community',
                              prefixIcon: Icons.description,
                                 validator: (p0) {
                               
                                if(p0.length > 500){
                                  return 'Community description is too long';
                                }
                              },
                              onSaved: (p0) {
                                createCommunityForm['Description'] = p0!;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 33,
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 20.0),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () async{
                                  ref.read(loadingProvider.notifier).setLoading(true);
                              if(_formkey.currentState!.validate()){
                                 
                                _formkey.currentState!.save(); 
                              String  response = await ref.read(singleCommunityStateProvider.notifier).createCommunity(createCommunityForm);
                                // call the provider to add community to backend
                                if(response.toLowerCase()=='success'){
                                  ref.read(loadingProvider.notifier).setLoading(false);
                                 NavigatorState cntxt=   Navigator.of(context);
                                 cntxt.pop();
                                 cntxt.push(MaterialPageRoute(builder: (context)=>const CommunityCreationView2()));
                                        //  Navigator.push(
                                        //    context,
                                        //    MaterialPageRoute(builder: (context) => CommunityCreationView2()),
                                        //  );
                                }

                                else{
                                   ref.read(loadingProvider.notifier).state=false;
                                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text(response),
                                      duration: const Duration(seconds: 3),
                                    ));
                                }
                              }
                                                            


  },
                            child:isLoading? const CustomProgressIndicator():  const Text('Next'),

                          )
                        )
                      )
                   
                  ],
                ),
              )
            )
          ),
        )
      ),
    );
  }
}