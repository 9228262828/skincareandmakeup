import 'package:Gomla/shared/utils/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DeleteAccount extends StatelessWidget {
  const DeleteAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.shade100,
          title: Text(AppLocalizations.of(context)!.deleteAccount),
        ),
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  deleteAccount(context);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: mediaQueryHeight(context) * 0.135,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.deleteAccount,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 18)),
                        SizedBox(height: mediaQueryHeight(context) * 0.01),
                        Text(AppLocalizations.of(context)!.deleteAccountWarning,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12)),
                        SizedBox(height: mediaQueryHeight(context) * 0.01),
                        Text(AppLocalizations.of(context)!.deleteMyAccount,
                            style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }

  void deleteAccount(context) {
    // Delete account
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.grey.shade100,
              title: Text(AppLocalizations.of(context)!.deleteAccount),
              content: Text(AppLocalizations.of(context)!.deleteAccountWarning),
              actions: [
                TextButton(
                  child: Text(AppLocalizations.of(context)!.cancel),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                    AppLocalizations.of(context)!.deleteAccount,
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
  }
}
