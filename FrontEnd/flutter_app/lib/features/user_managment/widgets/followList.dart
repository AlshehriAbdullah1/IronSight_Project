import 'package:flutter/material.dart';
import 'package:iron_sight/Common%20Widgets/smallFollowButton.dart';
import 'package:iron_sight/features/user_managment/views/profile_page_view.dart';

class FollowList extends StatelessWidget {
  final List<dynamic> accounts;
  final AssetImage avatar;

  const FollowList({
    Key? key,
    required this.avatar,
    required this.accounts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (var user in accounts)
            InkWell(
              onTap: () {
                // Handle the click event here
                // load the user account first
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileView(),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: CircleAvatar(
                          backgroundImage: avatar,
                          radius: 25,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['Display_Name']!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            user['User_Name']!,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                  smallFollowButton(
                    onClicked: () {},
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
