import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/features/tournament_managment/controller/tournament_provider.dart';
import 'package:iron_sight/models/user.dart';

class ResultsTab extends ConsumerStatefulWidget {
  const ResultsTab({Key? key}) : super(key: key);

  @override
  _ResultsTabState createState() => _ResultsTabState();
}

class _ResultsTabState extends ConsumerState<ResultsTab> {
  late Future<UserModel?> winnerData;

  @override
  void initState() {
    super.initState();
  
      winnerData = ref.read(singleTournamentStateProvider.notifier).getWinnerData();
   
  }
  @override
  Widget build(BuildContext context) {

    
       return FutureBuilder<UserModel?>(
      future: winnerData,
      builder: (BuildContext context, AsyncSnapshot<UserModel?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('An error occurred!'));
        } else if (snapshot.hasData) {
          // Return the winner information using the displayName and avatarUrl
          return Column(
            children: [
              const SizedBox(height: 10),
              const Text('The Tournament Has Ended!',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 10),
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(snapshot.data!.profilepic),
              ),
              const SizedBox(height: 10),
              Text(
                'Winner: ${snapshot.data!.displayName}',
                style:  const TextStyle(
                  color: Colors.yellow,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
          
          
        } else {
          return const Center(
            child: Text('The Tournament Has Not Ended Yet'),
          );
        }
      },
    );
    } 
    // else {
    //   return Center(
    //     child: const Text('Tournament result is pending'),
    //   );
    // }
}
