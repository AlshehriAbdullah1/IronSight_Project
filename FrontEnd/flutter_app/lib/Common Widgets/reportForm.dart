import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

String? dropdownValue = 'Inappropriate behavior';
final _formKey = GlobalKey<FormState>();
final _textController = TextEditingController();

class ReportForm extends StatefulWidget {
  const ReportForm({
    Key? key,
  }) : super(key: key);

  @override
  _ReportFormState createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  String? dropdownValue = 'Inappropriate behavior';
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xff381A57).withOpacity(0.7),
      titleTextStyle: Theme.of(context).textTheme.titleMedium,
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.30,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                  width: 254,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Misconduct type:",
                                style: Theme.of(context).textTheme.titleMedium),
                          ),
                          SizedBox(
                            width: 254,
                            child: DropdownButton<String>(
                              dropdownColor:
                                  const Color.fromRGBO(91, 41, 143, 1),
                              value: dropdownValue,
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                              onChanged: (String? newValue) {
                                setState(() {
                                  dropdownValue = newValue;
                                });
                              },
                              items: <String>[
                                'Inappropriate behavior',
                                'spamming',
                                'Bot'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Describe the issue:",
                              style: Theme.of(context).textTheme.titleMedium),
                          TextFormField(
                            controller: _textController,
                            maxLength: 500,
                            decoration: const InputDecoration(
                              hintText: 'Tell us more...',
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 254,
                        child: ElevatedButton(
                          child: Text(
                            "Submit",
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate() &&
                                dropdownValue != null) {
                              _textController.clear();
                              Navigator.of(context).pop();
                            }
                          },
                          style: ButtonStyle(
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry>(
                              const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 0),
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(
                              const Color.fromRGBO(136, 69, 205, 1),
                            ),
                            foregroundColor: MaterialStateProperty.all<Color>(
                              Colors.white,
                            ),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

void reportFormPopUp(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const ReportForm();
    },
  ).then((_) {
    _textController.clear(); // Clear the text when the dialog is dismissed
  });
}
