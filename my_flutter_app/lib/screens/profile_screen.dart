import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../widgets/app_bar_custom.dart';
import '../state/app_state.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    _nameController = TextEditingController(text: appState.displayName);
    _bioController = TextEditingController(text: appState.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePhoto(BuildContext context, AppState appState) async {
    final l10n = AppLocalizations.of(context)!;
    if (!appState.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.loginToChangePhoto)),
      );
      return;
    }

    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.camera),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.gallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            if (appState.profilePhotoUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(l10n.deletePhoto, style: const TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteProfilePhoto(context, appState);
                },
              ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final pickedFile = await picker.pickImage(source: source, maxWidth: 800, maxHeight: 800, imageQuality: 85);
      if (pickedFile != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.uploadingPhoto)),
        );

        // Read bytes for all platforms - image_picker supports this
        final fileData = await pickedFile.readAsBytes();
        final photoUrl = await appState.uploadProfilePhoto(fileData);

        if (!mounted) return;
        if (photoUrl != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.photoUpdated)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.photoUploadError)),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.error}: $e')),
      );
    }
  }

  Future<void> _deleteProfilePhoto(BuildContext context, AppState appState) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deletePhotoConfirm),
        content: Text(l10n.deletePhotoConfirmText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await appState.setProfilePhoto(null);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.photoDeleted)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBarCustom(title: l10n.profile),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    onTap: () => _pickProfilePhoto(context, appState),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: appState.avatarColor,
                      backgroundImage: appState.profilePhotoUrl != null
                          ? NetworkImage(appState.profilePhotoUrl!)
                          : null,
                      child: appState.profilePhotoUrl == null
                          ? const Icon(Icons.person, size: 48, color: Colors.white)
                          : null,
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => _pickProfilePhoto(context, appState),
                    icon: const Icon(Icons.camera_alt_outlined),
                    tooltip: l10n.changePhoto,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.name,
                prefixIcon: const Icon(Icons.badge_outlined),
              ),
              onSubmitted: (v) => appState.setDisplayName(v.trim()),
              onChanged: (v) {},
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bioController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.aboutMe,
                prefixIcon: const Icon(Icons.info_outline),
              ),
              onSubmitted: (v) => appState.setBio(v.trim()),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                await appState.setDisplayName(_nameController.text.trim());
                await appState.setBio(_bioController.text.trim());
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.profileSaved)),
                );
              },
              icon: const Icon(Icons.save_outlined),
              label: Text(l10n.saveProfile),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _StatCard(
                  title: l10n.messages,
                  value: appState.isLoggedIn ? appState.messageCount.toString() : '0',
                ),
                const SizedBox(width: 12),
                _StatCard(
                  title: l10n.consecutiveDays,
                  value: appState.isLoggedIn ? appState.consecutiveDays.toString() : '0',
                ),
                const SizedBox(width: 12),
                _StatCard(title: l10n.model, value: appState.selectedModel),
              ],
            ),
            const SizedBox(height: 20),
            if (!appState.isLoggedIn)
              Card(
                elevation: 0,
                color: scheme.surfaceVariant.withOpacity(0.5),
                child: ListTile(
                  leading: const Icon(Icons.login),
                  title: Text(l10n.loginOrRegister),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: scheme.surfaceVariant.withOpacity(0.5),
              child: ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: Text(l10n.appTheme),
                subtitle: Text(appState.themeMode == ThemeMode.dark ? l10n.dark : l10n.light),
                trailing: Switch(
                  value: appState.themeMode == ThemeMode.dark,
                  onChanged: (v) => appState.setThemeMode(v ? ThemeMode.dark : ThemeMode.light),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: scheme.surfaceVariant.withOpacity(0.5),
              child: ListTile(
                leading: const Icon(Icons.memory_outlined),
                title: Text(l10n.aiModel),
                subtitle: Text(appState.selectedModel),
                onTap: () async {
                  final model = await showModalBottomSheet<String>(
                    context: context,
                    showDragHandle: true,
                    builder: (context) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(title: Text(l10n.selectModel)),
                            for (final m in const ['gpt-3.5-turbo', 'gpt-4o', 'o4-mini'])
                              RadioListTile<String>(
                                value: m,
                                groupValue: appState.selectedModel,
                                title: Text(m),
                                onChanged: (v) => Navigator.of(context).pop(v),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                  if (model != null) {
                    await appState.setSelectedModel(model);
                  }
                },
              ),
            ),
            if (appState.isLoggedIn) ...[
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: scheme.surfaceVariant.withOpacity(0.5),
                child: ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(l10n.logout),
                  subtitle: Text(appState.email ?? ''),
                  onTap: () async {
                    await appState.logout();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.loggedOut)));
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}




