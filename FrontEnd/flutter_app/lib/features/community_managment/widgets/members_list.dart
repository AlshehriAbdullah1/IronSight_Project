import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:iron_sight/Common%20Widgets/MainPage.dart';
class MembersView extends ConsumerWidget {
   MembersView({super.key});
 int _currentIndex = 3;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
       extendBody: true,
      extendBodyBehindAppBar: true,
      body: null,
      
    );
  }
}


