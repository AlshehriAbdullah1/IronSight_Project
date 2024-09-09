import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/APIs/auth_api_client.dart';
import 'package:iron_sight/Common%20Widgets/reportForm.dart';
import 'package:iron_sight/features/community_managment/controller/community_provider.dart';
import 'package:iron_sight/features/community_managment/views/blocked_members_view.dart';
import 'package:iron_sight/features/user_managment/controller/auth_provider.dart';
import 'package:iron_sight/features/user_managment/controller/user_provider.dart';
import 'package:iron_sight/features/user_managment/views/profile_edit_view.dart';

class myAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final bool isOwner;
  final String profileImage;
  final String bannerImage;
  final VoidCallback? editFunction;
  final VoidCallback? shareFunction;
  final String? appBarType;
  final bool isVerified;

  const myAppBar({
    Key? key,
    required this.isOwner,
    required this.profileImage,
    required this.bannerImage,
    required this.isVerified,
    this.editFunction,
    this.shareFunction,
    this.appBarType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.2,
      // the property below can be refactored to handle profile view
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const <StretchMode>[
          StretchMode.zoomBackground,
          StretchMode.blurBackground
        ],
        background: Padding(
          padding:
              const EdgeInsets.only(bottom: 40), // adjust this value as needed
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              SizedBox.expand(
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: NetworkImage(bannerImage),
                    fit: BoxFit.cover,
                  )),
                ),
              ),
              Positioned(
                                    bottom: -40,
                    left: 20, 
                    child:               Stack(
                children: [
                  Positioned(
// adjust this value as needed
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(profileImage),
                    ),
                  ),
                      if (isVerified) // assuming you have a variable named isVerified
      Positioned(
        bottom: 0,
        right: 0,
        child: Icon(Icons.check_circle, color: Colors.purple[300]), // verified check mark
      ),
                ],
              ),)
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      iconTheme: const IconThemeData(size: 20.0),
      leading: isOwner
          ? null
          : Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.6)),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    if (appBarType == 'Community') {
                      ref
                          .read(communityListStateProvider.notifier)
                          .loadCommunities(isHomeView: true);
                    }
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: Colors.black.withOpacity(0.6)),
            child: PopupMenuButton<String>(
              color: const Color.fromRGBO(91, 41, 143, 1),
              onSelected: (value) {},
              itemBuilder: (BuildContext context) {
                List<PopupMenuItem<String>> items = [
                  // PopupMenuItem<String>(
                  //   value: 'share',
                  //   child: Text(
                  //     'Share',
                  //     style: Theme.of(context).textTheme.titleSmall,
                  //   ),
                  //   onTap: () {
                  //     if (shareFunction != null) {
                  //       shareFunction!();
                  //     }
                  //   },
                  // ),
                ];

                if (!isOwner) {
                  items.addAll([
                    PopupMenuItem<String>(
                      value: 'report',
                      child: Text(
                        'Report',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      onTap: () {
                        reportFormPopUp(context);
                      },
                    ),
                  ]);
                }

                if (isOwner) {
                  items.addAll([
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text(
                        'Edit',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      onTap: () {
                        if (editFunction != null) {
                          editFunction!();
                        }
                      },
                    ),
                  ]);
                }

                if (appBarType == 'Community' && isOwner) {
                  // i guess we shall add  "&& isOwner"

                  items.addAll([
                    PopupMenuItem<String>(
                      value: 'blockedUsers',
                      child: Text(
                        'Blocked Users',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return const BlockedMembersView();
                        }));
                      },
                    ),
                  ]);
                }

                return items; // here we can remove unwanted items eg... report
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
