import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/features/game_managment/controller/game_provider.dart';
import 'package:iron_sight/features/game_managment/controller/game_suggestion_provider.dart';
import 'package:iron_sight/main.dart';
import 'package:iron_sight/Common%20Widgets/regular_CustomTextfieldForm.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';

import 'package:iron_sight/Common%20Widgets/customDropDownMenuField.dart';

final _formkey = GlobalKey<FormState>();

final loadingProvider =
    StateNotifierProvider.autoDispose<LoadingNotifier, bool>((ref) {
  return LoadingNotifier(); // Initialize the notifier
});

class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false); // Initialize with false

  void setLoading(bool isLoading) {
    state = isLoading; // Update the state
  }
}

class SuggestGame extends ConsumerStatefulWidget {
  const SuggestGame({Key? key}) : super(key: key);

  @override
  ConsumerState<SuggestGame> createState() => _SuggestGameState();
}

class _SuggestGameState extends ConsumerState<SuggestGame> {
  String? _selectedValue;
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _gameNameController = TextEditingController();
  final TextEditingController _gameDescriptionController =
      TextEditingController();
  final TextEditingController _gameGenreController = TextEditingController();
  final TextEditingController _gamePlatformController = TextEditingController();
  String? _selectedGenre;
  @override
  void dispose() {
    _gameNameController.dispose();
    _gameDescriptionController.dispose();
    _gameGenreController.dispose();
    _gamePlatformController.dispose();
    _selectedGenre = null;
    super.dispose();
  }

  final List<String> _gameGenres = ['Shooter', 'FPS', 'RPG', 'Sports'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 56, 5, 97),
          title:const Text('Suggest a Game'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(

          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formkey,
                    child: Column(
                      children: <Widget>[
                        const SizedBox(
                          height: 150,
                        ),
                        Text('Game Name:',
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        CustomTextFormField(
                          controller: _gameNameController,
                          hintText: 'Enter Game Name',
                          onSaved: (p0) {},
                            validator: (p0) {
                            if (p0.isEmpty){
                              return 'Please Enter Game Name';
                            }
                            else if (p0.length> 50){
                              return 'Please Enter a shorter game name';
                            }
                            else{
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 40),
                        Text('Game Description:',
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        CustomTextFormField(
                          controller: _gameDescriptionController,
                          hintText: 'Enter Game Description',
                  
                          onSaved: (p0) {},
                          validator: (p0) {
                            if (p0.isEmpty){
                              return 'Please Enter Game Description';
                            }
                            else if (p0.length> 100){
                              return 'Please Enter a shorter description';
                            }
                            else{
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 40),
                        Text('Game Genre:',
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        DropdownButton(
                            value: _selectedValue,
                            items: const [
                              DropdownMenuItem(
                                  child: Text('Shooter'), value: 'Shooter'),
                              DropdownMenuItem(child: Text('FPS'), value: 'FPS'),
                              DropdownMenuItem(child: Text('RPG'), value: 'RPG'),
                              DropdownMenuItem(
                                  child: Text('Sports'), value: 'Sports'),
                            ],
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedValue = newValue;
                              });
                            },
                            ),
                        const SizedBox(height: 40),
                                 
                        Align(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: () async {
                              if(_formkey.currentState!.validate()){
                                // wait for 2 seconds

                              await  Future.delayed(const Duration(seconds: 1));


                                ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Suggestion Sent, Thank You!'),
                                ),
                              );
                              Navigator.pop(context);
                              }
                              
                              
                            },
                            child: const Text('Submit'),
                          ),
                        ),
                      //  const SizedBox(
                      //     height: 130,
                      //   )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),);
  }
}
