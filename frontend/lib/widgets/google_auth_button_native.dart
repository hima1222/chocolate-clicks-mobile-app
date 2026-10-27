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
      foregroundColor: const Color(0xFFE6D3BD),
      minimumSize: const Size(0, 48),
      side: const BorderSide(color: Color(0xFFBDA892)),
    ),
  );
}
