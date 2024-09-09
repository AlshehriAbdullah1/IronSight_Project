import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/features/community_managment/controller/community_provider.dart';

class CommunityCard extends ConsumerStatefulWidget {
  final String communityImage;
  final String communityName;
  final String communityId;
  final String communityDescription;
  final String? communityPassword;
  final bool communityIsVerfied;

  const CommunityCard({
    Key? key,
    required this.communityImage,
    required this.communityName,
    required this.communityDescription,
    required this.communityId,
    required this.communityPassword,
    required this.communityIsVerfied,
  }) : super(key: key);

  @override
  _CommunityCardState createState() => _CommunityCardState();
}

class _CommunityCardState extends ConsumerState<CommunityCard> {
  @override
  Widget build(BuildContext context) {
    final communities = ref.watch(communityListStateProvider);
    final isFollowing = ref
        .watch(communityListStateProvider.notifier)
        .isUserFollowing(widget.communityId);
    final isOwner = ref
        .watch(communityListStateProvider.notifier)
        .isOwner(widget.communityId);
    final isModerator = ref
        .watch(communityListStateProvider.notifier)
        .isModerator(widget.communityId);
    final isOwnerOrModerator = ref
        .watch(communityListStateProvider.notifier)
        .isOwnerOrModerator(widget.communityId);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        width: 390.0,
        child: Card(
          color: const Color(0xFF50188B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 114.0,
                      height: 174.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        image: widget.communityPassword != null &&
                                widget.communityPassword!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(widget.communityImage),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                    Colors.black.withOpacity(0.5),
                                    BlendMode.dstATop),
                              )
                            : DecorationImage(
                                image: NetworkImage(widget.communityImage),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    if ((isOwnerOrModerator || isFollowing)&&
                      (widget.communityPassword != null &&
                        widget.communityPassword!.isNotEmpty))
                      const Positioned(
                        top: 8,
                        right: 8,
                        child: Icon(
                          Icons.lock_open,
                          color: Colors.white,
                        ),
                      )
                    else if (widget.communityPassword != null &&
                        widget.communityPassword!.isNotEmpty)
                      const Positioned(
                        top: 8,
                        right: 8,
                        child: Icon(
                          Icons.lock,
                          color: Colors.white,
                        ),
                      ),
                  ],
                  
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.communityName,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if(widget.communityIsVerfied)
                        const Row(
                          children: [
                             Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 20,
                            ),
                             Text(
                              'Verified',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 8),
                      Text(
                        ' ${widget.communityDescription}',
                        style: Theme.of(context).textTheme.bodyLarge,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 4,
                      ),
                      
                      SizedBox(height: 16),
                      // if(widget.communityPassword != null &&
                      //   widget.communityPassword!.isNotEmpty)
                      //   const Text(
                      //     'Private Community',
                      //     style: TextStyle(
                      //       color: Colors.red,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      if (!isOwnerOrModerator && 
                          
                          (widget.communityPassword == null ||
                              widget.communityPassword!.isEmpty))
                        Column(
                          children: [
                            SizedBox(
                              height: 35,
                              width: 200,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (isFollowing) {
                                    try {
                                      await ref
                                          .read(communityListStateProvider
                                              .notifier)
                                          .unFollowCommunity(
                                              widget.communityId);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(
                                          e.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ));
                                    }
                                  } else {
                                    try {
                                      await ref
                                          .read(communityListStateProvider
                                              .notifier)
                                          .followCommunity(widget.communityId);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(
                                          e.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ));
                                    }
                                  }
                                },
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all<
                                      EdgeInsetsGeometry>(
                                    const EdgeInsets.symmetric(
                                        horizontal: 0, vertical: 0),
                                  ),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    isFollowing
                                        ? const Color.fromRGBO(91, 41, 143, 1)
                                        : const Color.fromRGBO(136, 69, 205,
                                            1),
                                  ),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Colors.white,
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
                        )
                      else if (isOwner)
                        Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: const Text(
                                'Owner',
                                style: TextStyle(
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        )
                      else if (isModerator)
                        Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: const Text(
                                'Moderator',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        )
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