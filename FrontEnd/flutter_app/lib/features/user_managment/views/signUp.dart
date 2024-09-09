import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/Common%20Widgets/MainPage.dart';
import 'package:iron_sight/features/community_managment/views/community_creation_view.dart';
import 'package:iron_sight/features/user_managment/controller/auth_provider.dart';
import 'package:iron_sight/features/user_managment/controller/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/Common%20Widgets/regular_CustomTextfieldForm.dart';
import 'package:iron_sight/APIs/user_api_client.dart';
import 'package:iron_sight/features/user_managment/views/completeSignUp.dart';
import 'package:iron_sight/features/user_managment/views/game_preference_view.dart';
import 'package:iron_sight/features/user_managment/views/profile_page_view.dart';
import 'package:iron_sight/features/user_managment/views/signIn.dart';
import 'package:iron_sight/features/user_managment/widgets/signUpButton.dart';

// final signUpProvider = Provider((ref) => UserApiClient());

class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false); // Initialize with false

  void setLoading(bool isLoading) {
    state = isLoading; // Update the state
  }
}

class SignUp extends ConsumerStatefulWidget {
  const SignUp({super.key});

  @override
  ConsumerState<SignUp> createState() => _SignUpState();
}

class _SignUpState extends ConsumerState<SignUp> {
  final pendingProvider = StateProvider<bool>((ref) => false);
  final TextEditingController _EmailController = TextEditingController();
  final TextEditingController _PasswordController = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  late Map<String, String> createUserForm;

  @override
  void initState() {
    super.initState();
    createUserForm = {
      'email': '',
      'password': '',
      'phone': '',
    };
  }

  @override
  void dispose() {
    super.dispose();
    _EmailController.dispose();
    _PasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 153),
            child: Form(
              key: _formkey,
              child: Column(children: [
                isLoading
                    ? const Center(
                        child: CustomProgressIndicator(),
                      )
                    : Container(
                        height: 165,
                        width: 165,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/IronSightLogo.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                const SizedBox(
                  height: 50,
                ),
                Text(
                  "Sign Up",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email Address',
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(
                          height: 5,
                        ),
                        CustomTextFormField(
                          controller: _EmailController,
                          hintText: 'email@gmail.com',
                          prefixIcon: Icons.email,
                          onSaved: (p0) {
                            // createUserForm['email'] = p0;
                          },
                        ),
                      ]),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Password',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(
                        height: 5,
                      ),
                      CustomTextFormField(
                        controller: _PasswordController,
                        hintText: '********',
                        prefixIcon: Icons.key,
                        obscureText: true,
                        onSaved: (p0) {
                          // createUserForm['password'] = p0;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                
                ElevatedButton(
                    onPressed: () async {
                      if (_formkey.currentState!.validate()) {
                        _formkey.currentState!.save();
                        try {
                          ref.read(loadingProvider.notifier).setLoading(true);
                          final signResponse = await ref
                              .read(authControllerProvider.notifier)
                              .signUp(_EmailController.text,
                                  _PasswordController.text);
                          ref.read(loadingProvider.notifier).setLoading(false);
                          if (signResponse) {
                            NavigatorState cntxt = Navigator.of(context);
                            cntxt.pop();
                            cntxt.push(MaterialPageRoute(
                                builder: (context) => const CompleteSignUp()));
                          } else {
                            NavigatorState cntxt = Navigator.of(context);
                            cntxt.pop();
                            cntxt.push(MaterialPageRoute(
                                builder: (context) => const MainPage()));
                          }
                        }  catch (e) {
                          ref.read(loadingProvider.notifier).setLoading(false);
                          ScaffoldMessenger.of(context)
                              .showSnackBar( SnackBar(
                            content: Text('error in sign up $e'),
                            duration: const Duration(seconds: 2),
                          ));
                        }
                      }
                    },
                    child: ref.read(pendingProvider.notifier).state
                        ? const CustomProgressIndicator()
                        : const Text('Sign Up')),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                   Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Already have an account?",
                    style: TextStyle(
                        fontSize: 10,
                        color: Color.fromARGB(255, 255, 98, 0),
                        fontFamily: "Inter",
                        decoration: TextDecoration.underline),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
