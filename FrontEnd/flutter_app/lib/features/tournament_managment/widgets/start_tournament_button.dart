import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/Common%20Widgets/popUpScreen.dart';
import 'package:iron_sight/features/tournament_managment/controller/tournament_provider.dart';

final loadingProvider =
    StateNotifierProvider.autoDispose<LoadingNotifier, bool>((ref) {
  return LoadingNotifier(); // Initialize the notifier
});

class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false); // Initialize with false

  void setLoading(bool isLoading) {
    state = isLoading; // Update the state
  }
}

class StartTournamentButton extends ConsumerStatefulWidget {
  final bool isStarted;
  final bool isFull;
  final bool isEnded;
  const StartTournamentButton({super.key,required this.isStarted,required this.isFull,required this.isEnded});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StartTournamentButtonState();
}

class _StartTournamentButtonState extends ConsumerState<StartTournamentButton> {

  @override
  Widget build(BuildContext context) {
    
     final isTournamentStarted = widget.isStarted;
     final isTournamentEnded = widget.isEnded;
     
     final isLoading = ref.watch(loadingProvider);
    return SizedBox(
      height: 40,
      width: 254,
      child: ElevatedButton(
        onPressed: ()  async{
          if(isLoading || isTournamentEnded || widget.isFull)return;
          ref.read(loadingProvider.notifier).setLoading(true);
          if(isTournamentStarted){
            ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(
                  content: Text("The tournament is already started!"),
                  duration:  Duration(seconds: 2),
                ),
              );
            return;
          } 
          if(widget.isFull){
            ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(
                  content: Text("The tournament is not ready to start!"),
                  duration:  Duration(seconds: 2),
                ),
              );
            return;
          } 
          if(isTournamentEnded){
            ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(
                  content: Text("The tournament has already ended!"),
                  duration:  Duration(seconds: 2),
                ),
              );
            return;
          } 
          if(!isLoading){
             try {
           //show confirmation to start 
          showPopUp(context, 'Are you sure you want to start the tournament?', ()async{
              await ref.read(singleTournamentStateProvider.notifier).startTournament();
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(
                  content: Text("Successfully started!"),
                  duration:  Duration(seconds: 2),
                ),
              );
          });

          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString(),),duration: const Duration(seconds: 2),
              ),
            );
          }
          }
         
           ref.read(loadingProvider.notifier).setLoading(false);
          
        },
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(
            isTournamentStarted
                ? const Color.fromRGBO(91, 41, 143, 1)
                : const Color.fromRGBO(136, 69, 205, 1),
          ),
          foregroundColor: MaterialStateProperty.all<Color>(
            Colors.white,
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
        ),
        child:isLoading?const CircularProgressIndicator(): Text(
          
          isTournamentStarted
              ? "Tournament has started"
              : widget.isFull? 'Tournament is not ready to start': isTournamentEnded?'Tournament has ended':"Start Tournament",
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
    );
  }
}