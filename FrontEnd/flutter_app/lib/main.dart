import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/Common%20Widgets/MainPage.dart';
import 'package:iron_sight/features/community_managment/views/communitiesView.dart';
import 'package:iron_sight/features/search_managment/Views/searchView.dart';
import 'package:iron_sight/features/user_managment/controller/auth_provider.dart';
import 'package:iron_sight/features/user_managment/controller/user_provider.dart';
import 'package:iron_sight/features/user_managment/views/completeSignUp.dart';
import 'package:iron_sight/features/user_managment/views/game_preference_view.dart';
import 'package:iron_sight/features/user_managment/views/profile_page_view.dart';
import 'package:iron_sight/features/user_managment/views/signUp.dart';
import 'package:iron_sight/features/user_managment/views/signIn.dart';
import 'package:iron_sight/models/tournament.dart';
import 'package:iron_sight/theme/theme.dart';
import 'package:iron_sight/features/tournament_managment/views/tournament_creation_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// import 'firebase_options.dart';

import 'package:iron_sight/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(
    name: 'IronSight',
    options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
// final authProvider = ref.watch(authControllerProvider);

    return MaterialApp(
      title: 'Iron Sight',
      themeMode: ThemeMode.dark,
      darkTheme: MyAppTheme.darkTheme,
      theme: MyAppTheme.lightTheme,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator()); // Show loading indicator while waiting for data
          } else if (snapshot.hasData && snapshot.data != null) {
            final uid = snapshot.data!.uid;
            Future(() async {
              ref.read(userProvider.notifier).loadUser(snapshot.data!.uid);
            });
            return ref.watch(isNewUserProvider(uid)).when(
                  data: (isNewUser) =>
                      isNewUser ? const SignIn() : const MainPage(),
                  error: (_, __) => const Text('Error loading user data'),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                );
          } else {
            return const SignIn(); // User is signed out
          }
        },
      ),
    );
// return MaterialApp(
//       title: 'Iron Sight',
//       themeMode: ThemeMode.dark,
//       darkTheme: MyAppTheme.darkTheme,
//       theme: MyAppTheme.lightTheme,
//       home:const Scaffold(body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [CustomProgressIndicator()],
//       ),)
//     );
  }
}
