import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

String? dropdownValue = 'Any Time';
final _formKey = GlobalKey<FormState>();
final _textController = TextEditingController();

class FilterFormPopUp extends StatefulWidget {
  const FilterFormPopUp({
    Key? key,
  }) : super(key: key);

  @override
  _FilterFormPopUpState createState() => _FilterFormPopUpState();
}

class _FilterFormPopUpState extends State<FilterFormPopUp> {
  String? dropdownValue = 'Any Time';
  bool _isCheckedOnline = true;
  bool _isCheckedInPerson = true;
  String _radioValue = 'Newest';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xff381A57).withOpacity(0.7),
      titleTextStyle: Theme.of(context).textTheme.titleMedium,
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.34,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Tournament Type:",
                              style: Theme.of(context).textTheme.titleMedium),
                          Row(
                            children: [
                              Flexible(
                                  child: CheckboxListTile(
                                contentPadding: const EdgeInsets.all(0),
                                title: const Text("Online"),
                                value: _isCheckedOnline,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isCheckedOnline = value!;
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              )),
                              Flexible(
                                child: CheckboxListTile(
                                  contentPadding: const EdgeInsets.all(0),
                                  title: const Text("In-Person"),
                                  value: _isCheckedInPerson,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _isCheckedInPerson = value!;
                                    });
                                  },
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Sort By:",
                              style: Theme.of(context).textTheme.titleMedium),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: RadioListTile<String>(
                                  title: const Text('Newest'),
                                  value: 'Newest',
                                  groupValue: _radioValue,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _radioValue = value!;
                                    });
                                  },
                                  contentPadding: EdgeInsets.all(0),
                                ),
                              ),
                              Flexible(
                                child: RadioListTile<String>(
                                  title: const Text('Popular'),
                                  value: 'Popular',
                                  groupValue: _radioValue,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _radioValue = value!;
                                    });
                                  },
                                  contentPadding: EdgeInsets.all(0),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Time:",
                                style: Theme.of(context).textTheme.titleMedium),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
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
                                'Any Time',
                                'This Month',
                                'This Week',
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
                      const SizedBox(height: 10),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
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

void FilterPopUp(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const FilterFormPopUp();
    },
  );
}
