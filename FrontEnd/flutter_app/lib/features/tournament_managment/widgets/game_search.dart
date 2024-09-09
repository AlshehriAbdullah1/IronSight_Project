import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/models/game.dart';
import 'package:iron_sight/features/game_managment/controller/game_suggestion_provider.dart';
class GameSearchField extends ConsumerStatefulWidget {
  const GameSearchField({
    Key? key,
    required this.onGameSelected,
  }) : super(key: key);

  final Function(Game) onGameSelected;

  @override
  ConsumerState<GameSearchField> createState() => _GameSearchFieldState();
}

class _GameSearchFieldState extends ConsumerState<GameSearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = ref.watch(gameSuggestionProvider(_controller.text));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Search for a game',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 10),
        suggestions.when(
          data: (games) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                return GameSuggestionTile(
                  game: game,
                  onTap: () {
                    widget.onGameSelected(game);
                    _controller.clear();
                  },
                );
              },
            );
          },
          error: (error, stackTrace) => Text('Error: $error'),
          loading: () => const CircularProgressIndicator(),
        ),
      ],
    );
  }
}

class GameSuggestionTile extends StatelessWidget {
  const GameSuggestionTile({
    Key? key,
    required this.game,
    required this.onTap,
  }) : super(key: key);

  final Game game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(game.gameName),
      onTap: onTap,
    );
  }
}