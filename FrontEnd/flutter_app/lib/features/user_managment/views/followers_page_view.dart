import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/features/user_managment/controller/user_provider.dart';
import 'package:iron_sight/features/user_managment/widgets/FollowList.dart';

final ownerProvider = StateProvider<bool>((ref) => false);

class FollowersView extends ConsumerStatefulWidget {
  const FollowersView({super.key});

  @override
  ConsumerState<FollowersView> createState() => _FollowersViewState();
}

class _FollowersViewState extends ConsumerState<FollowersView>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  int _currentIndex = 3; //For the bottom navigation bar

  @override
  Widget build(BuildContext context) {
    final userDetails = ref.watch(userProvider);
    final isOwner = ref.read(userProvider.notifier).isOwner;
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/background.jpg'), fit: BoxFit.cover),
        ),
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                backgroundColor: Colors.transparent,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.6)),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ),
            ];
          },
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/background.jpg'),
                  fit: BoxFit.cover),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
              child: ListView(
                padding: const EdgeInsets.only(top: 10),
                children: [
                  FollowList(
                    avatar: const AssetImage('assets/avatar1.jpg'),
                    accounts:
                        userDetails != null && userDetails.user!.Followers != null
                            ? userDetails.user!.Followers as List<dynamic>
                            : [],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
