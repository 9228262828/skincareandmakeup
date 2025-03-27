
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PrivacyPolicyPage extends StatefulWidget {
  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  String slug = '';
  String content = '';

  @override
  void initState() {
    super.initState();
    fetchPrivacyPolicyData();
  }

  Future<void> fetchPrivacyPolicyData() async {
      String _tokenKey = 'auth_token';

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_tokenKey);

    print(prefs.getString(_tokenKey));
    final url = Uri.parse('https://gomla.sa/wp-json/wp/v2/pages/3',);
    final response = await http.get(url,
      headers: {
        "gomla_auth": 'Bearer $token',

    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        slug = data['slug'];
        content = stripHtmlTags(data['content']['rendered']);
      });
    } else {
      throw Exception('Failed to load privacy policy');
    }
  }

  // Function to strip HTML tags
  String stripHtmlTags(String htmlString) {
    final RegExp exp = RegExp(r'<[^>]*>');
    return htmlString.replaceAll(exp, '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( AppLocalizations.of(context)!.privacyPolicy,),
        backgroundColor: Colors.white,
        surfaceTintColor:   Colors.white,
        leading:  IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: slug.isEmpty || content.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              " $slug",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),


            SizedBox(height: 10),
            Text(
              content,
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
