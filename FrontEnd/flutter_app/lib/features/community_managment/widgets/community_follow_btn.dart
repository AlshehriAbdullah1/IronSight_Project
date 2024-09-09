import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:iron_sight/features/community_managment/controller/community_provider.dart';
//create consumer widget for follow button

class CommunityFollowButton extends ConsumerWidget {
  // community id
  final String communityId;
  const CommunityFollowButton({Key? key, required this.communityId})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFollowing =
        ref.watch(singleCommunityStateProvider.notifier).isMember();
    return Column(
      children: [
        SizedBox(
          height: 35,
          width: 85,
          child: ElevatedButton(
            onPressed: () async {
              if (isFollowing) {
                try {
                  await ref
                      .read(singleCommunityStateProvider.notifier)
                      .unFollowCommunity();
                } catch (e) {
                  // Scaffold messanger

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      e.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ));
                }
              } else {
                try {
                  await ref
                      .read(singleCommunityStateProvider.notifier)
                      .followCommunity();
                } catch (e) {
                  // Scaffold messanger

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      e.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ));
                }
              }
            },
            style: ButtonStyle(
              // Set horizontal and vertical padding
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              ),
              // Change background color
              backgroundColor: MaterialStateProperty.all<Color>(
                isFollowing
                    ? const Color.fromRGBO(91, 41, 143, 1)
                    : const Color.fromRGBO(136, 69, 205,
                        1), // Replace with your preferred background color
              ),
              // Change foreground (text) color
              foregroundColor: MaterialStateProperty.all<Color>(
                Colors.white, // Replace with your preferred text color
              ),
            ),
            child: Text(
              isFollowing ? 'Unfollow' : 'Follow',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
