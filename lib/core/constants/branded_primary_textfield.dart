import 'package:flutter/material.dart';

class BrandedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final double height;
  final TextInputType? keyboardType;
  final Widget? prefix;
  final Widget? sufix;
  final bool isFilled;
  final void Function(String)? onChanged;
  final int maxLines;
  final int minLines;
  final bool isEnabled;
  final bool isPassword;
  final void Function()? onTap;
  final String? Function(String?)? validator;
  final Color? backgroundColor;

  const BrandedTextField({
    super.key,
    this.validator,
    this.isEnabled = true,
    this.isFilled = true,
    required this.controller,
    this.prefix,
    required this.labelText,
    this.height = 60,
    this.sufix,
    this.maxLines = 1,
    this.minLines = 1,
    this.keyboardType,
    this.onChanged,
    this.onTap,
    this.isPassword = false,
    this.backgroundColor,
  });

  @override
  _BrandedTextFieldState createState() => _BrandedTextFieldState();
}

class _BrandedTextFieldState extends State<BrandedTextField> {
  bool _isObscured = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const Color borderColor = Colors.white;
    const Color focusedBorderColor = Colors.white;
    const Color labelColor = Colors.white;
    const Color hintColor = Colors.white70;
    const Color textColor = Colors.white;
    const Color iconColor = Colors.white;
    const Color errorColor = Colors.redAccent;

    return Focus(
      onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: TextFormField(
          validator: widget.validator,
          enabled: widget.isEnabled,
          onTap: widget.onTap,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          obscureText: widget.isPassword ? _isObscured : false,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
          decoration: InputDecoration(
            fillColor: Colors.transparent,
            // fillColor: widget.backgroundColor ?? Colors.transparent,
            filled: widget.isFilled,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: borderColor, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: focusedBorderColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: borderColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: errorColor, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: errorColor, width: 2),
            ),

            hintText: widget.labelText,
            hintStyle: const TextStyle(color: hintColor, fontSize: 14),

            label: Text(
              widget.labelText,
              style: const TextStyle(color: labelColor, fontSize: 14),
            ),

            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _isObscured
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: iconColor,
                    ),
                    onPressed: () => setState(() => _isObscured = !_isObscured),
                  )
                : widget.sufix != null
                ? IconTheme(
                    data: const IconThemeData(color: iconColor),
                    child: widget.sufix!,
                  )
                : null,

            prefixIcon: widget.prefix != null
                ? IconTheme(
                    data: const IconThemeData(color: iconColor),
                    child: widget.prefix!,
                  )
                : null,

            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 20,
            ),

            errorStyle: const TextStyle(color: errorColor, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
