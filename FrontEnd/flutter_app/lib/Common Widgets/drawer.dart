import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/Common%20Widgets/Support.dart';
import 'package:iron_sight/features/community_managment/views/community_creation_view.dart';
import 'package:iron_sight/features/tournament_managment/views/tournament_creation_view.dart';
import 'package:iron_sight/features/user_managment/controller/auth_provider.dart';
import 'package:iron_sight/features/user_managment/views/SignIn.dart';
import 'package:iron_sight/Common%20Widgets/suggest_game.dart';

class TopLeftDrawer extends ConsumerWidget {
  const TopLeftDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use your providers here
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Image.asset('assets/Logo.png'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.sports_esports),
                    title: const Text('Create a Tournament'),
                    titleTextStyle: Theme.of(context).textTheme.titleMedium,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TournamentCreationView()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.group),
                    title: const Text('Create a Community'),
                    titleTextStyle: Theme.of(context).textTheme.titleMedium,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const CommunityCreationView()),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.gamepad),
                    title: const Text('Suggest a Game'),
                    titleTextStyle: Theme.of(context).textTheme.titleSmall,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SuggestGame()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.support_agent),
                    title: const Text('Support'),
                    titleTextStyle: Theme.of(context).textTheme.titleSmall,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SupportPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Sign Out'),
                    titleTextStyle: Theme.of(context).textTheme.titleSmall,
                    onTap: () {
                      ref.read(authControllerProvider.notifier).signOut();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const SignIn()),
                        (Route<dynamic> route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Made With ',
                      style: Theme.of(context).copyWith().textTheme.titleMedium,
                    ),
                    TextSpan(
                      text: '❤️',
                      style: Theme.of(context)
                          .copyWith()?.textTheme.titleMedium?.copyWith(color: Colors.red),
                    ),
                    TextSpan(
                      text: ' in KFUPM',
                      style: Theme.of(context).copyWith().textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
