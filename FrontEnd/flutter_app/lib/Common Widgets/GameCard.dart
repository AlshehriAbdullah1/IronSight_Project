import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/features/game_managment/controller/game_provider.dart';
import 'package:iron_sight/features/user_managment/controller/user_provider.dart';

class GameCard extends ConsumerStatefulWidget {
  final String gameId;
  final String gameimage;
  final String gameName;
  final String gameDecsription;
  const GameCard({
    Key? key,
    required this.gameId,
    required this.gameimage,
    required this.gameName,
    required this.gameDecsription,
  }) : super(key: key);

  @override
  _GameCardState createState() => _GameCardState();
}

class _GameCardState extends ConsumerState<GameCard> {
  @override
  Widget build(BuildContext context) {
    final userState= ref.watch(userProvider);
    final isFollowing = ref.watch(userProvider.notifier).isFollowingGameUsingGameId(widget.gameId);
    // final followedGames = ref.watch(userGamesProvider);
    // final isFollowing = followedGames.value
    //         ?.where((game) => game.gameName == widget.gameName)
    //         .isNotEmpty ??
    //     false;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        width: 390.0,
        child: Card(
          color: Color(0xFF50188B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 114.0,
                  height: 174.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    image: DecorationImage(
                      image: NetworkImage(widget.gameimage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.gameName,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.gameDecsription,
                        style: Theme.of(context).textTheme.bodyLarge,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 35,
                        width: 200,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (isFollowing) {
                              try {
                                await ref
                                    .read(preferencesProvider.notifier)
                                    .Unfollowgame(widget.gameId);
                              } catch (e) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                    e.toString(),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ));
                              }
                            } else {
                              try {
                                await ref
                                    .read(preferencesProvider.notifier)
                                    .followGame(widget.gameId);
                              } catch (e) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                    e.toString(),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ));
                              }
                            }
                          },
                          style: ButtonStyle(
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry>(
                              const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 0),
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(
                               isFollowing
                                    ? const Color.fromRGBO(91, 41, 143, 1)
                                    : const Color.fromRGBO(136, 69, 205, 1)),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                          ),
                          child: Text(
                            isFollowing ? 'Unfollow' : 'Follow',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
