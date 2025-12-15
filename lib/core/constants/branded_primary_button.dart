import 'package:flutter/material.dart';

// const Color kPrimaryColor = Color.fromRGBO(51, 107, 63, 1);
const Color kPrimaryColor = Color.fromRGBO(201, 248, 186, 1);

class BrandedPrimaryButton extends StatelessWidget {
  final String name;
  final VoidCallback onPressed;
  final bool isEnabled;
  final bool isUnfocus;
  final bool isTextBlack; // ✅ NEW
  final Widget? suffixIcon;
  final Color primaryColor;

  const BrandedPrimaryButton({
    super.key,
    this.isUnfocus = false,
    required this.name,
    required this.onPressed,
    this.isEnabled = true,
    this.suffixIcon,
    this.primaryColor = kPrimaryColor,
    this.isTextBlack = true, // ✅ default value
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SizedBox(
        height: isEnabled ? 56 : 56,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled
                ? (isUnfocus ? Colors.white : primaryColor)
                : theme.disabledColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isEnabled ? 10.0 : 6.0),
              side: isEnabled
                  ? BorderSide(color: primaryColor, width: 1.2)
                  : BorderSide.none,
            ),
          ),
          child: getButtonText(context),
        ),
      ),
    );
  }

  Widget getButtonText(BuildContext context) {
    final theme = Theme.of(context);

    // ✅ Text color priority logic
    Color textColor;
    if (isTextBlack) {
      textColor = Colors.black;
    } else {
      textColor = isUnfocus ? primaryColor : Colors.white;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          name,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: (MediaQuery.of(context).size.width < 380) ? 14 : 16,
          ),
        ),
        if (suffixIcon != null) ...[const SizedBox(width: 8), suffixIcon!],
      ],
    );
  }
}
