import 'package:flutter/material.dart';
import '../widgets/shop_page.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _auth = AuthService();
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    _name.text = user?.fullName ?? '';
    _email.text = user?.email ?? '';
    _phone.text = user?.phone ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      final parts = _name.text.trim().split(RegExp(r'\s+'));
      final response = await _auth.updateProfile(
        firstName: parts.first,
        lastName: parts.skip(1).join(' '),
        phone: _phone.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.success ? 'Profile information saved' : response.message,
          ),
        ),
      );
      if (response.success) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is AuthException
                ? e.message
                : 'Unable to save your profile. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => ShopPage(
    title: 'Edit Profile',
    subtitle:
        'A little about you. Keep your contact details up to date for your next sweet visit.',
    bottomBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: FilledButton.icon(
          onPressed: _saving ? null : _save,
          style: FilledButton.styleFrom(
            backgroundColor: shopGold,
            foregroundColor: shopBackground,
            padding: const EdgeInsets.all(18),
          ),
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: Text(_saving ? 'Saving...' : 'Save Changes'),
        ),
      ),
    ),
    children: [
      ShopPanel(
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: shopGold,
              child: Text(
                _name.text.trim().isEmpty
                    ? '?'
                    : _name.text.trim()[0].toUpperCase(),
                style: const TextStyle(
                  color: shopBackground,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _name.text.trim().isEmpty
                        ? 'Your profile'
                        : _name.text.trim(),
                    style: const TextStyle(
                      color: shopCream,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Chocolate Clicks member',
                    style: TextStyle(color: shopGold, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      ShopPanel(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personal details',
                style: TextStyle(
                  color: shopCream,
                  fontSize: 22,
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _name,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: shopCream),
                textCapitalization: TextCapitalization.words,
                decoration: shopInput('Full Name', Icons.person_outline),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name required' : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _email,
                readOnly: true,
                style: const TextStyle(color: Colors.white60),
                decoration: shopInput('Email', Icons.email_outlined).copyWith(
                  suffixIcon: const Icon(
                    Icons.lock_outline,
                    color: Colors.white38,
                    size: 18,
                  ),
                  helperText: 'Your sign-in email',
                  helperStyle: const TextStyle(color: Colors.white54),
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: shopCream),
                decoration: shopInput('Phone Number', Icons.phone_outlined),
                validator: (v) =>
                    v == null ||
                        !RegExp(r'^\+?[0-9]{10,15}$').hasMatch(v.trim())
                    ? 'Enter a valid phone number'
                    : null,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
