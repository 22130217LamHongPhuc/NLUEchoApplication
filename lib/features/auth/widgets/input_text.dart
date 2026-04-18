import 'package:echo_nlu/core/constants/app_colors.dart';
import 'package:echo_nlu/core/constants/app_radius.dart';
import 'package:flutter/material.dart';

class InputText extends StatefulWidget {
  final String label;
  final String hint;
  final IconData leadingIcon;
  final IconData? trailingIcon;
  final TextInputType type;
  final void Function(String) onChanged;
  final bool isPassword;
  final String? errorText;
  bool obscureText;
  final TextEditingController controller;
  InputText({super.key, required this.label, required this.hint,
    required this.onChanged, required this.leadingIcon, required this.type,
    this.trailingIcon,
    this.isPassword = false,
    this.errorText,
    this.obscureText = false,
    required  this.controller
  });

  @override
  State<InputText> createState() => _InputTextState();
}

class _InputTextState extends State<InputText> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 3.0),
          child:  Text(
            widget.label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff4b5b72)
            ),
          ),
        ),
        const SizedBox(height: 8),

        TextField(
          controller: widget.controller,
          keyboardType: widget.type,
          onChanged: widget.onChanged,
          obscureText: _obscure,
          style: TextStyle(color: Color(0xff7688a0)),
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            hintStyle: TextStyle(color: Color(0xff94A3B8)),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 16),
              child: Icon(widget.leadingIcon, color: Color(0xff94A3B8)),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 16),
              child: GestureDetector(
                  onTap: () {
                    if (widget.isPassword) {
                      setState(() {
                        _obscure = !_obscure;
                      });
                    }
                  },
                  child: Icon(_obscure ? widget.trailingIcon : Icons.remove_red_eye_outlined , color: Color(0xff94A3B8))),
            ),

            filled: true,
            fillColor: Color(0xffF8FAFC),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.textMuted),
            ),
          ),
        ),
      ],
    );
  }
}
