import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../contstants.dart';
import '../shared/utils/app_values.dart';

class StackOver extends StatefulWidget {
  final TextEditingController notesController;

  const StackOver({super.key, required this.notesController});

  @override
  _StackOverState createState() => _StackOverState();
}

class _StackOverState extends State<StackOver> {
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set the default text in the controller when the widget is first built
    if (_selectedIndex == 0) {
      widget.notesController.text = AppLocalizations.of(context)!.house;
    } else {
      widget.notesController.text = AppLocalizations.of(context)!.work;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: List.generate(
        2,
            (index) {
          bool isSelected = index == _selectedIndex;
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                  // Update the notesController based on selection
                  widget.notesController.text = index == 0
                      ? AppLocalizations.of(context)!.house
                      : AppLocalizations.of(context)!.work;
                });
              },
              child: Container(
                height: 40,
                width: mediaQueryWidth(context) * .25,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? mainColor : Color(0xFFEAEAEA),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        index == 0
                            ? AppLocalizations.of(context)!.house
                            : AppLocalizations.of(context)!.work,
                        style: TextStyle(
                          color: isSelected ? mainColor : Color(0xFFEAEAEA),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      index == 0 ? Icons.home_outlined : Icons.work_outline,
                      color: isSelected ? mainColor : Color(0xFFEAEAEA),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
