
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class PasswordField extends StatefulWidget {
  final TextEditingController passwordController ;
  final String name;
  const PasswordField({super.key, required this.passwordController, required this.name});

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {

   bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.passwordController,
      obscureText: _obscureText,
      decoration: InputDecoration(
        contentPadding:   EdgeInsets.symmetric(horizontal: 8,vertical: 0),
        labelText: widget.name,
        hintText: widget.name,
        labelStyle:   TextStyle(color: Color(0xFFD9D9D9),fontSize: 14)  ,
        hintStyle:   TextStyle(color: Color(0xFFD9D9D9),fontSize: 14)  ,
        prefixIcon: Icon(Icons.lock,size: 20,color:  Color(0xFFDC9D1E),),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;  // Toggle visibility
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
              color: Color(0xFFEAEAEA),
              width:
              1), // Yellow border when the field is enabled
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
              color: Color(0xFFEAEAEA).withOpacity(.8),
              width: 1), // Green border when focused
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
              color: Colors.red,
              width: 1), // Red border for error state
        ),
        errorStyle: TextStyle(fontSize: 12), // Adjust the error message size
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.pleaseEnterYourPassword;
        }
        return null;
      },
    );
  }
}