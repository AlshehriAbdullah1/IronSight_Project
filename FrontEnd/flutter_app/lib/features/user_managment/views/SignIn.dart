import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/Common%20Widgets/MainPage.dart';
import 'package:iron_sight/features/community_managment/views/community_creation_view.dart';
// import 'package:iron_sight/features/user_managment/controller/user_provider.dart';
import 'package:iron_sight/Common%20Widgets/regular_CustomTextfieldForm.dart';
import 'package:iron_sight/features/user_managment/controller/user_provider.dart';
import 'package:iron_sight/features/user_managment/views/completeSignUp.dart';
import 'package:iron_sight/features/user_managment/views/profile_page_view.dart';
import 'package:iron_sight/features/user_managment/views/signUp.dart';
import 'package:iron_sight/features/user_managment/widgets/signInButton.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iron_sight/features/user_managment/controller/auth_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false); // Initialize with false

  void setLoading(bool isLoading) {
    state = isLoading; // Update the state
  }
}

class SignIn extends ConsumerStatefulWidget {
  const SignIn({super.key});

  @override
  ConsumerState<SignIn> createState() => _SignInState();
}

class _SignInState extends ConsumerState<SignIn> {

  final TextEditingController _EmailController = TextEditingController();
  final TextEditingController _PasswordController = TextEditingController();
  final TextEditingController _PhoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    _EmailController.dispose();
    _PasswordController.dispose();
    _PhoneController.dispose();
  }

  Future<void> _launchStartGgSignIn() async {
    try {
      String startGgSignInUrl = getStartGgAuthUrl();
      if (await canLaunchUrl(Uri.parse(startGgSignInUrl))) {
        await launchUrl(Uri.parse(startGgSignInUrl),
            mode: LaunchMode.inAppBrowserView);
      } else {
        throw 'Could not launch $startGgSignInUrl';
      }
    } catch (error) {
    }
  }

  Future<void> _launchGoogleSignIn() async {
    try {
      String googleSignInUrl = getGoogleAuthUrl();
      if (await canLaunchUrl(Uri.parse(googleSignInUrl))) {
        await launchUrl(Uri.parse(googleSignInUrl),
            mode: LaunchMode.inAppBrowserView);
      } else {
        throw 'Could not launch $googleSignInUrl';
      }
    } catch (error) {
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uriLinkStream.listen((Uri? link) {
      if (link != null) {
        handleSignInListener(link);
      } else {
      }
    });
  }

  void handleSignInListener(Uri link) async {
    final customToken = link.queryParameters['customToken'];

    if (customToken != null) {
      // sign is success
      try {
        bool? isNewUser = await ref
            .read(authControllerProvider.notifier)
            .signInUsingThirdParty(customToken);

        if (isNewUser) {
          if (mounted) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) {
                return const CompleteSignUp();
              },
            ));
          }
        } else {
          if (mounted) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) {
                return const MainPage();
              },
            ));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 2),
              content: Text('${e}'),
            ),
          );
        }
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    final UserProvider = ref.watch(userProvider);
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
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
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
                  "Sign In",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 30,
                ),
                ///// start of the email address textfield
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
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
                          validator: (p0) {
                            String email = _EmailController.text.trim();
                            if (email.isEmpty) {
                              return 'Please enter an email address';
                            }
                            if (!RegExp(
                                    r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                                .hasMatch(email)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                          onSaved: (p0) {
                            // do email validation
                          },
                        ),
                      ]),
                ),
                const SizedBox(height: 15),
                ///// start of the password textfield
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                  ),
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
                        obscureText: true,
                        hintText: '********',
                        prefixIcon: Icons.key,
                        onSaved: (p0) {},
                        validator: (p0) {
                          if (p0.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (p0.length < 8) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),
                SignInButton(onClicked: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final email = _EmailController.text;
                    final password = _PasswordController.text;
                    ref.read(loadingProvider.notifier).setLoading(true);
                    try {
                      await ref
                          .read(authControllerProvider.notifier)
                          .signIn(email, password).then((value) {
                               ref.read(loadingProvider.notifier).setLoading(false);
                             if (mounted) {
                      ref.read(loadingProvider.notifier).setLoading(false);
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) {
                          return const MainPage();
                        },
                      ));
                    }
                          });
                      
                    } catch (e) {
                         ref.read(loadingProvider.notifier).setLoading(false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                   
                  
                  }
                }),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "or Connect with",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.start,
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      child: Container(
                        height: 40,
                        width: 117,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Center(
                          child: Container(
                            height: 22,
                            width: 22,
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                              image: AssetImage('assets/startGG.png'),
                              fit: BoxFit.cover,
                            )),
                          ),
                        ),
                      ),
                      onTap: () {
                        _launchStartGgSignIn();
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      child: Container(
                        height: 40,
                        width: 117,
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(100, 172, 241, 1),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Center(
                          child: Container(
                            height: 29,
                            width: 29,
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                              image: AssetImage('assets/googleLogo.png'),
                              fit: BoxFit.cover,
                            )),
                          ),
                        ),
                      ),
                      onTap: () {
                        _launchGoogleSignIn();
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: <TextSpan>[
                      const TextSpan(text: "Don't have an account? "),
                      TextSpan(
                        text: 'Sign Up',
                        style: const TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Navigate to the sign-up page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUp()),
                            );
                          },
                      ),
                    ],
                  ),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

String getStartGgAuthUrl() {
   String startGgClientId = dotenv.env['START_GG_CLIENT_ID']!;
   String startGgRedirectUrl =dotenv.env['START_GG_REDIRECT_URL']!;
  String rootUrl = dotenv.env['START_GG_ROOT_URL']!;

  final options = {
    'response_type': 'code',
    'client_id': startGgClientId,
    'scope': 'user.identity user.email',
    'redirect_uri': startGgRedirectUrl,
  };

  Uri uri = Uri(queryParameters: options);

  String queryString = uri.query;

  return "$rootUrl?$queryString".replaceAll('+', "%20");
}

String getGoogleAuthUrl() {
  
   String googleClientId =dotenv.env['GOOGLE_CLOUD_CLIENT_ID']!;
   String googleOauthRedirectUrl =dotenv.env['GOOGLE_OAUTH_REDIRECT_URL']!;
  String rootUrl = dotenv.env['GOOGLE_ROOT_URL']!;
  final options = {
    'redirect_uri': googleOauthRedirectUrl,
    'client_id': googleClientId,
    'access_type': 'offline',
    'response_type': 'code',
    'prompt': 'consent',
    'scope': [
      'https://www.googleapis.com/auth/userinfo.profile',
      'https://www.googleapis.com/auth/userinfo.email'
    ].join(" "),
  };
// print(options);
  Uri uri = Uri(queryParameters: options);
  String queryString = uri.query;
// print(uri.toString());

// print('\n\n\n${rootUrl}?${queryString.toString()}');
  return '${rootUrl.toString()}?${queryString.toString()}';
}
