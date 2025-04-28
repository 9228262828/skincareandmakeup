import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../contstants.dart';
import '../shared/global/app_theme.dart';
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
  void initState() {
    super.initState();
    // Don't put any dependency on Localizations here
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Safely access Localizations here
    final houseText = AppLocalizations.of(context)!.house;
    final workText = AppLocalizations.of(context)!.work;
    final currentText = widget.notesController.text;

    // Set selected index based on the controller's text
    if (currentText == houseText) {
      _selectedIndex = 0;
    } else if (currentText == workText) {
      _selectedIndex = 1;
    } else if (currentText.isNotEmpty) {
      _selectedIndex = 2;
    }

    // Make sure the default value is set if nothing is selected
    if (_selectedIndex == 0 && widget.notesController.text.isEmpty) {
      widget.notesController.text = houseText;  // Set house as the default
    }
  }

  @override
  Widget build(BuildContext context) {
    final houseText = AppLocalizations.of(context)!.house;
    final workText = AppLocalizations.of(context)!.work;
    final customLabel = AppLocalizations.of(context)!.custom;

    List<String> labels = [houseText, workText, customLabel];
    List<IconData> icons = [
      Icons.home_outlined,
      Icons.work_outline,
      Icons.edit_outlined
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          children: List.generate(3, (index) {
            bool isSelected = index == _selectedIndex;

            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;

                    if (index == 0) {
                      widget.notesController.text = houseText;
                    } else if (index == 1) {
                      widget.notesController.text = workText;
                    } else {
                      widget.notesController.text = '';  // Clear text when custom is selected
                    }
                  });
                },
                child: Container(
                  height: 40,
                  width: mediaQueryWidth(context) * .25,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? mainColor : const Color(0xFFEAEAEA),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icons[index],
                        color: isSelected ? mainColor : const Color(0xFFEAEAEA),
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        labels[index],
                        style: TextStyle(
                          color: isSelected ? mainColor : const Color(0xFFEAEAEA),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
        if (_selectedIndex == 2)  // Show the custom input field when custom is selected
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TextFormField(
              controller: widget.notesController,
              onChanged: (value) {
                // No need to manually store this anymore
              },
              decoration: customInputDecoration(
                prefixIcon:
                Localizations.localeOf(context).languageCode == 'ar'
                    ? const Icon(
                  Icons.note_alt_sharp,
                  size: 20,
                  color: Color(0xFFDC9D1E),
                )
                    : Directionality(
                  textDirection: TextDirection.ltr,
                  child: const Icon(
                    Icons.person_2_rounded,
                    size: 20,
                    color: Color(0xFFDC9D1E),
                  ),
                ),
                context,
                AppLocalizations.of(context)!.enterCustomNote,
                AppLocalizations.of(context)!.enterCustomNote,
              ),
            ),
          ),
      ],
    );
  }
}
