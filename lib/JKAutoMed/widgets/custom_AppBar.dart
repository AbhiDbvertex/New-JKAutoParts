import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JKCustomAppbar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const JKCustomAppbar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(

      backgroundColor: Colors.white, // normal
      elevation: 0, // flat
      leading: leading,
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Aclonica', // ✔ font same
          fontSize: 18, // normal
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      centerTitle: true, // standard Android
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
