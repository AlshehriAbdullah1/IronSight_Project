import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/Common%20Widgets/MainPage.dart';
import 'package:iron_sight/Common%20Widgets/drawer.dart';
import 'package:iron_sight/features/game_managment/controller/game_provider.dart';
import 'package:iron_sight/features/user_managment/views/profile_page_view.dart';

// create loading provider

class GamePreferenceView extends ConsumerStatefulWidget {
  const GamePreferenceView({super.key});

  @override
  _GamePreferenceViewState createState() => _GamePreferenceViewState();
}

class _GamePreferenceViewState extends ConsumerState<GamePreferenceView> {
  @override
  Widget build(BuildContext context) {
    final gamesFuture = ref.watch(gamesProvider);
    final selectedGamesProvider = ref.watch(preferencesProvider);
    final loading = ref.watch(loadingProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: selectedGamesProvider.isNotEmpty
          ? FloatingActionButton(
              onPressed: () async {
                // Submit the preferences
                try {
                  await ref
                      .read(preferencesProvider.notifier)
                      .submitPreferences();
                  NavigatorState cntxt = Navigator.of(context);
                  cntxt.pop();
                  cntxt.push(MaterialPageRoute(
                      builder: (context) => const MainPage()));
                } catch (e) {
                  // show snack bar of the error message\
                  selectedGamesProvider.clear();

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      e.toString(),
                    ),
                    duration: const Duration(seconds: 2),
                  ));
                }
              },
              child: const Icon(Icons.check),
            )
          : null,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Search'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MainPage()),
              );
            },
          ),
        ],
      ),
      drawer: const TopLeftDrawer(),
      body: Stack(
        children: [
          const Positioned.fill(
            child: Image(
              image: AssetImage('assets/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Color(0xFF707070)),
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: Icon(Icons.filter_list),
                        filled: true,
                        fillColor: Color(0xFF242424),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Choose games that you like!',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MainPage()),
                            );
                          },
                          child: Text('or skip>',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: const Color(0xFFBA90FF),
                                  )),
                        ),
                      ],
                    ),
                  ),
                  gamesFuture.when(
                    data: (data) {
                      return Stack(children: [
                        SingleChildScrollView(
                          child: SizedBox(
                            child: GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 3,
                              childAspectRatio: 100 / 135,
                              children: data.map((game) {
                                return GestureDetector(
                                  onTap: () {
                                    if (!ref
                                        .read(preferencesProvider.notifier)
                                        .isSelectedPreference(game.id)) {
                                      ref
                                          .read(preferencesProvider.notifier)
                                          .addPreference(game.id);
                                    } else {
                                      ref
                                          .read(preferencesProvider.notifier)
                                          .removePreference(game.id);
                                    }
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  game.mainPicture.toString(),
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (ref
                                          .read(preferencesProvider.notifier)
                                          .isSelectedPreference(game.id))
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Container(
                                            color: const Color(0xCC000000),
                                          ),
                                        ),
                                      if (ref
                                          .read(preferencesProvider.notifier)
                                          .isSelectedPreference(game.id))
                                        const Center(
                                          child: Icon(Icons.thumb_up_outlined,
                                              color: Color(0xFF8759E2)),
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        if (loading)
                          Container(
                            color: Colors.blue.withOpacity(0.3),
                            child: const Center(
                              child: CustomProgressIndicator(),
                            ),
                          ),
                      ]);
                    },
                    error: (error, stackTrace) {
                      return Center(
                        child: Text(
                          'Error: $error',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    },
                    loading: () {
                      return const Center(child: CustomProgressIndicator());
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
