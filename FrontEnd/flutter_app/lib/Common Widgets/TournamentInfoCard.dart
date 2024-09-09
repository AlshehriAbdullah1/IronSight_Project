import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_sight/features/tournament_managment/views/tournament_management_view.dart';

class TournamentInfoCard extends ConsumerStatefulWidget {
  final String tournamentId;
  final String tournamentimage;
  final String tournamenName;
  final String tournamentDate;
  final String tournamentGame;
  final String tournamentType;
  final String tournamentOrg;

  TournamentInfoCard({
    required this.tournamentimage,
    required this.tournamenName,
    required this.tournamentDate,
    required this.tournamentGame,
    required this.tournamentType,
    required this.tournamentOrg,
    required this.tournamentId,
  });

  @override
  _TournamentInfoCardState createState() => _TournamentInfoCardState();
}

class _TournamentInfoCardState extends ConsumerState<TournamentInfoCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Handle the click event here
      
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
            return   TournamentManagementView(tournamentId: widget.tournamentId,);
            }
          ),
        );
      },
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          width: 390.0,
          child: Card(
            color: Color(0xFF50188B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 114.0,
                    height: 174.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          5.0), // Adjust the value as needed
                      image: DecorationImage(
                        image: NetworkImage(
                          widget.tournamentimage,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                 const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.tournamenName.length > 20 
    ? widget.tournamenName.substring(0, 20) 
    : widget.tournamenName,
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.date_range,
                            ),
                            SizedBox(width: 8),
                            Text(
                              ' ${widget.tournamentDate}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.gamepad_outlined,
                            ),
                            SizedBox(width: 8),
                            Text(
                              widget.tournamentGame.length > 20 
    ? 
    '${widget.tournamentGame.substring(0, 20)}..' 
    : widget.tournamentGame,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                           const Icon(Icons.category_rounded),
                          const  SizedBox(width: 8),
                            Text(
                              ' ${widget.tournamentType}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                       const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                          const  Icon(Icons.business),
                           const SizedBox(width: 8),
                            Text(
                             widget.tournamentOrg.length > 20 
    ? '${widget.tournamentOrg.substring(0, 20)}...' 
    : widget.tournamentOrg,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ],
                    ),
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
