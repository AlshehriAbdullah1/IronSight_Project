import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/Common%20Widgets/CustomProgressIndicator.dart';
import 'package:iron_sight/features/user_managment/controller/user_provider.dart';
import 'package:iron_sight/features/user_managment/widgets/FollowList.dart';

final ownerProvider = StateProvider<bool>((ref) => false);

class FollowingView extends ConsumerStatefulWidget {
  const FollowingView({super.key});

  @override
  ConsumerState<FollowingView> createState() => _FollowingViewState();
}

class _FollowingViewState extends ConsumerState<FollowingView>
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
        child: userDetails.isLoading
            ? const CustomProgressIndicator()
            : userDetails.error != null
                ? const Text('Error loading the page, from the provider')
                : NestedScrollView(
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
                                icon: const Icon(Icons.arrow_back,
                                    color: Colors.white),
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
                              avatar: const AssetImage('assets/avatar2.jpg'),
                              accounts: userDetails != null &&
                                      userDetails.user!.Following != null
                                  ? userDetails.user!.Following as List<dynamic>
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
