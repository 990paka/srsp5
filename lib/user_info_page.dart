import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  Map<String, String> _data = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _data = {
        'Full Name': prefs.getString('name') ?? '—',
        'Phone Number': prefs.getString('phone') ?? '—',
        'Email': prefs.getString('email') ?? '—',
        'Life Story': prefs.getString('story') ?? '—',
      };
      _loading = false;
    });
  }

  Future<void> _clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pop(context);
  }

  IconData _icon(String label) {
    switch (label) {
      case 'Full Name':
        return Icons.person;
      case 'Phone Number':
        return Icons.phone;
      case 'Email':
        return Icons.mail;
      default:
        return Icons.notes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Info'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final e in _data.entries)
                  Card(
                    child: ListTile(
                      leading: Icon(_icon(e.key), color: Colors.blue),
                      title: Text(e.key,
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(e.value,
                          style: const TextStyle(fontSize: 16, color: Colors.black87)),
                    ),
                  ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: _clear,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Clear saved data'),
                ),
              ],
            ),
    );
  }
}