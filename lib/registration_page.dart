import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_info_page.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  // Controller для каждого поля
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _storyController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmController = TextEditingController();

  // FocusNode для каждого поля
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _storyFocus = FocusNode();
  final _passFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _hidePass = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    for (final c in [
      _nameController,
      _phoneController,
      _emailController,
      _storyController,
      _passController,
      _confirmController,
    ]) {
      c.dispose();
    }
    for (final f in [
      _nameFocus,
      _phoneFocus,
      _emailFocus,
      _storyFocus,
      _passFocus,
      _confirmFocus,
    ]) {
      f.dispose();
    }
    super.dispose();
  }

  // ---------- Валидаторы ----------

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Name is required';
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required';
    if (!RegExp(r'^\d+$').hasMatch(v.trim())) {
      return 'Phone number must contain digits only';
    }
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w.+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$');
    if (!regex.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != _passController.text) return 'Passwords do not match';
    return null;
  }

  // ---------- Отправка формы ----------

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Фокус на первое поле с ошибкой
      if (_validateName(_nameController.text) != null) {
        _nameFocus.requestFocus();
      } else if (_validatePhone(_phoneController.text) != null) {
        _phoneFocus.requestFocus();
      } else if (_validateEmail(_emailController.text) != null) {
        _emailFocus.requestFocus();
      } else if (_validatePassword(_passController.text) != null) {
        _passFocus.requestFocus();
      } else {
        _confirmFocus.requestFocus();
      }
      return;
    }

    // Сохраняем данные локально (пароль намеренно не сохраняем в открытом виде)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text.trim());
    await prefs.setString('phone', _phoneController.text.trim());
    await prefs.setString('email', _emailController.text.trim());
    await prefs.setString('story', _storyController.text.trim());

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserInfoPage()),
    );
  }

  // ---------- Вспомогательные виджеты ----------

  Widget _clearButton(TextEditingController controller) => IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: () => controller.clear(),
      );

  Widget _eyeButton(bool hidden, VoidCallback onTap) => IconButton(
        icon: Icon(hidden ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey),
        onPressed: onTap,
      );

  OutlineInputBorder _roundBorder([Color color = Colors.black87]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: color, width: 1.5),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Form'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Full Name
              TextFormField(
                controller: _nameController,
                focusNode: _nameFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
                validator: _validateName,
                decoration: InputDecoration(
                  labelText: 'Full Name *',
                  hintText: 'What do people call you?',
                  prefixIcon: const Icon(Icons.person),
                  suffixIcon: _clearButton(_nameController),
                  border: _roundBorder(),
                  enabledBorder: _roundBorder(),
                  focusedBorder: _roundBorder(Colors.blue),
                ),
              ),
              const SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: _phoneController,
                focusNode: _phoneFocus,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                validator: _validatePhone,
                decoration: InputDecoration(
                  labelText: 'Phone Number *',
                  hintText: 'Where can we reach you?',
                  helperText: 'Phone format: (XXX)XXX-XXXX',
                  prefixIcon: const Icon(Icons.phone),
                  suffixIcon: _clearButton(_phoneController),
                  border: _roundBorder(),
                  enabledBorder: _roundBorder(),
                  focusedBorder: _roundBorder(Colors.blue),
                ),
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _storyFocus.requestFocus(),
                validator: _validateEmail,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.mail),
                ),
              ),
              const SizedBox(height: 16),

              // Life Story
              TextFormField(
                controller: _storyController,
                focusNode: _storyFocus,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: 'Life Story',
                  helperText: 'Keep it short, this is just a demo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextFormField(
                controller: _passController,
                focusNode: _passFocus,
                obscureText: _hidePass,
                maxLength: 8,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _confirmFocus.requestFocus(),
                validator: _validatePassword,
                decoration: InputDecoration(
                  labelText: 'Password *',
                  prefixIcon: const Icon(Icons.security),
                  suffixIcon: _eyeButton(
                      _hidePass, () => setState(() => _hidePass = !_hidePass)),
                ),
              ),
              const SizedBox(height: 8),

              // Confirm Password
              TextFormField(
                controller: _confirmController,
                focusNode: _confirmFocus,
                obscureText: _hideConfirm,
                maxLength: 8,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: _validateConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirm Password *',
                  prefixIcon: const Icon(Icons.border_color),
                  suffixIcon: _eyeButton(_hideConfirm,
                      () => setState(() => _hideConfirm = !_hideConfirm)),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _submit,
                  child: const Text('Submit Form',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}