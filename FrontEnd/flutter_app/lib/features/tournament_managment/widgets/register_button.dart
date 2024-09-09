import 'package:flutter/material.dart';
import 'package:iron_sight/Common%20Widgets/popUpScreen.dart';
import 'package:iron_sight/features/tournament_managment/controller/tournament_provider.dart';
import 'package:iron_sight/features/user_managment/controller/auth_provider.dart';
import 'package:iron_sight/models/tournament.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class RegisterButton extends ConsumerStatefulWidget {
  List<Participant> particiapants;
  RegisterButton({
    Key? key,
    required this.particiapants,
  }) : super(key: key);

  @override
  _RegisterButtonState createState() => _RegisterButtonState();
}

class _RegisterButtonState extends ConsumerState<RegisterButton> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final tournamentState = ref.watch(singleTournamentStateProvider);
    // final tournamentNotifier = ref.watch(singleTournamentStateProvider.notifier);
    final isLoading = ref.watch(loadingProvider);
    final participantId =
        ref.read(authControllerProvider.notifier).getCurrentUserId();
    final isUserRegistered =
        widget.particiapants.any((par) => par.participantId == participantId);
    return SizedBox(
      height: 40,
      width: 254,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () async {
                ref.read(loadingProvider.notifier).setLoading(true);
                try {
                  if (isUserRegistered) {
                    showPopUp(context, "Are you sure you want to unregister?",
                        () async {
                      if (participantId != null) {
                        await ref
                            .read(singleTournamentStateProvider.notifier)
                            .unRegisterParticipant(participantId);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Successfully Unregistered!"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    });
                  } else {
                    //register here
                    if (participantId != null) {
                      await ref
                          .read(singleTournamentStateProvider.notifier)
                          .registerParticipant(participantId);
                      //show success
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Successfully Registered!"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  //scaffold messanger
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString(),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
                ref.read(loadingProvider.notifier).setLoading(false);
              },
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(
            isUserRegistered
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
        child: isLoading
            ? CircularProgressIndicator()
            : Text(
                isUserRegistered ? "Registered" : "Register",
                style: Theme.of(context).textTheme.titleSmall,
              ),
      ),
    );
  }
}
