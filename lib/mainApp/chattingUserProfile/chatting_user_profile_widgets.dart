import 'package:flutter/material.dart';

import '../../../reusable/colors.dart';

class ReusableIconContainer extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const ReusableIconContainer({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(3.0),
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: grey.withOpacity(0.2),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Icon(icon, color: white),
      ),
    );
  }
}
