import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart' as web;
import '../models/user_model.dart';
import '../services/auth_service.dart';

class GoogleAuthButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final ValueChanged<bool>? onBusyChanged;
  const GoogleAuthButton({super.key, this.onPressed, this.onBusyChanged});
  @override
  State<GoogleAuthButton> createState() => _GoogleAuthButtonState();
}

class _GoogleAuthButtonState extends State<GoogleAuthButton> {
  late Future<void> _initialization;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _subscription;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _subscription = GoogleSignIn.instance.authenticationEvents.listen(
      (event) {
        if (event is GoogleSignInAuthenticationEventSignIn) {
          _complete(event.user);
        }
      },
      onError: (Object error) {
        if (mounted) {
          _showError('Google sign-in could not complete. Please try again.');
        }
      },
    );
    _initialization = AuthService().initializeGoogle();
  }

  Future<void> _complete(GoogleSignInAccount account) async {
    if (!mounted ||
        ModalRoute.of(context)?.isCurrent == false ||
        _processing ||
        widget.onPressed == null) {
      return;
    }
    setState(() => _processing = true);
    widget.onBusyChanged?.call(true);
    try {
      await AuthService().completeGoogleSignIn(account);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/welcome_profile');
    } catch (error) {
      if (mounted) {
        _showError(
          error is AuthException
              ? error.message
              : 'Unable to finish Google sign-in. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _processing = false);
        widget.onBusyChanged?.call(false);
      }
    }
  }

  void _showError(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    future: _initialization,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done || _processing) {
        return const SizedBox(
          height: 48,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      }
      if (snapshot.hasError) {
        return Column(
          children: [
            const Text(
              'Google sign-in is unavailable. Check the backend connection and Google configuration.',
              style: TextStyle(color: Color(0xFFE6D3BD)),
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: () => setState(
                () => _initialization = AuthService().initializeGoogle(),
              ),
              child: const Text('Retry Google sign-in'),
            ),
          ],
        );
      }
      return IgnorePointer(
        ignoring: widget.onPressed == null,
        child: web.renderButton(
          configuration: web.GSIButtonConfiguration(
            theme: web.GSIButtonTheme.outline,
            size: web.GSIButtonSize.large,
            shape: web.GSIButtonShape.rectangular,
            text: web.GSIButtonText.continueWith,
          ),
        ),
      );
    },
  );
}
