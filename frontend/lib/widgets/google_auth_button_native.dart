import 'package:flutter/material.dart';
import 'app_image.dart';

class GoogleAuthButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final ValueChanged<bool>? onBusyChanged;
  const GoogleAuthButton({super.key, this.onPressed, this.onBusyChanged});

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: AppImage.asset(
      'assets/images/GL.png',
      width: 24,
      height: 24,
      fit: BoxFit.contain,
    ),
    label: const Text('Continue with Google'),
    style: OutlinedButton.styleFrom(
      backgroundColor: Colors.white,
      disabledBackgroundColor: Colors.white,
      foregroundColor: const Color(0xFF202124),
      disabledForegroundColor: Colors.grey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      minimumSize: const Size(0, 48),
      side: const BorderSide(color: Colors.white),
    ),
  );
}
