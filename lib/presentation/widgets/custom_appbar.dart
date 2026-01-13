import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool isShowBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color backgroundColor;
  final double elevation;
  final Widget? leading;
  final TextStyle? titleStyle;
  final bool centerTitle;
  final double toolbarHeight;

  const CustomAppBar({
    Key? key,
    this.title,
    this.isShowBackButton = true,
    this.onBackPressed,
    this.actions,
    this.backgroundColor = Colors.transparent,
    this.elevation = 0,
    this.leading,
    this.titleStyle,
    this.centerTitle = true,
    this.toolbarHeight = kToolbarHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      toolbarHeight: toolbarHeight,

      /// 🔙 Leading / Back Button
      leading: isShowBackButton
          ? leading ??
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: onBackPressed ?? () => Navigator.pop(context),
                    ),
                  ),
                )
          : leading,

      /// 📝 Title
      title: title != null
          ? Text(
              title!,
              style:
                  titleStyle ??
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
            )
          : null,

      /// ⚙️ Actions
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);
}
