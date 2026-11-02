import 'package:flutter/material.dart';

import '../data/models.dart';
import '../state/app_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar.dart';
import '../widgets/common.dart';
import 'login_screen.dart';

/// Profil: kişisel bilgiler, şifre ve bildirim ayarları.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final me = app.me;
    if (me == null) return const Scaffold();
    final settings = app.settings;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.only(top: 8, bottom: 40 + MediaQuery.of(context).padding.bottom),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  CircleButton(
                    icon: Icons.chevron_left_rounded,
                    tooltip: 'Geri',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 10),
                  Text('Profil', style: AppText.b(15, weight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(child: UserAvatar(user: me, size: 72)),
            const SizedBox(height: 12),
            Center(child: Text(me.fullName, style: AppText.d(29, height: 1.1))),
            const SizedBox(height: 6),
            Center(
              child: Text(
                '${me.isManager ? 'Yönetici' : 'Üye'} · AhsaTech',
                style: AppText.b(14, color: AppColors.muted),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: vgap([
                  SectionCard(
                    title: 'Kişisel bilgiler',
                    gap: 0,
                    children: [
                      const SizedBox(height: 6),
                      _FieldRow(
                        label: 'Ad',
                        value: me.firstName,
                        placeholder: 'Adın',
                        onTap: () => _edit(context, 'Ad', me.firstName, (v) => app.updateProfile(firstName: v)),
                      ),
                      const RowDivider(),
                      _FieldRow(
                        label: 'Soyad',
                        value: me.lastName,
                        placeholder: 'Soyadın',
                        onTap: () => _edit(context, 'Soyad', me.lastName, (v) => app.updateProfile(lastName: v)),
                      ),
                      const RowDivider(),
                      _FieldRow(
                        label: 'Telefon',
                        value: me.phone,
                        placeholder: '05xx xxx xx xx',
                        onTap: () => _edit(
                          context,
                          'Telefon',
                          me.phone,
                          (v) => app.updateProfile(phone: v),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const RowDivider(),
                      _FieldRow(label: 'E-posta', value: me.email, placeholder: '', locked: true),
                      const SizedBox(height: 8),
                      Text(
                        'Kayıtlı e-postanı sadece yönetici değiştirebilir.',
                        style: AppText.b(12, color: AppColors.muted, height: 1.45),
                      ),
                    ],
                  ),
                  SectionCard(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    children: [
                      InkWell(
                        onTap: () => showAppSheet<void>(context, (_) => const _PasswordSheet()),
                        child: SizedBox(
                          height: 56,
                          child: Row(
                            children: [
                              const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.ink),
                              const SizedBox(width: 12),
                              Expanded(child: Text('Şifre değiştir', style: AppText.b(15, weight: FontWeight.w500))),
                              const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SectionCard(
                    title: 'Bildirimler',
                    gap: 0,
                    children: [
                      const SizedBox(height: 6),
                      _ToggleRow(
                        label: 'Bana iş verildiğinde',
                        value: settings.onAssigned,
                        onChanged: (v) => app.saveSettings(settings.copyWith(onAssigned: v)),
                      ),
                      const RowDivider(),
                      _ToggleRow(
                        label: 'Teslim saati yaklaşınca',
                        value: settings.onDueSoon,
                        onChanged: (v) => app.saveSettings(settings.copyWith(onDueSoon: v)),
                      ),
                      const RowDivider(),
                      const SizedBox(height: 12),
                      Text('Sessize al', style: AppText.b(15, weight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoicePill(
                            label: '1 saat',
                            selected: settings.mute == MuteOption.oneHour,
                            onTap: () => app.saveSettings(settings.copyWith(mute: MuteOption.oneHour)),
                          ),
                          ChoicePill(
                            label: 'Yarın sabaha kadar',
                            selected: settings.mute == MuteOption.untilMorning,
                            onTap: () => app.saveSettings(settings.copyWith(mute: MuteOption.untilMorning)),
                          ),
                          ChoicePill(
                            label: 'Kapalı',
                            selected: settings.mute == MuteOption.off,
                            onTap: () => app.saveSettings(settings.copyWith(mute: MuteOption.off)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => _signOut(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.tomato,
                      minimumSize: const Size.fromHeight(52),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: Text('Çıkış yap', style: AppText.b(15, weight: FontWeight.w600, color: AppColors.tomato)),
                  ),
                ], 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    String title,
    String initial,
    Future<void> Function(String value) save, {
    TextInputType? keyboardType,
  }) async {
    final value = await askText(context, title: title, initial: initial, keyboardType: keyboardType);
    if (value == null) return;
    await save(value);
  }

  Future<void> _signOut(BuildContext context) async {
    final app = AppScope.read(context);
    final navigator = Navigator.of(context);
    final ok = await confirm(
      context,
      title: 'Çıkış yapılsın mı?',
      message: 'Tekrar girmek için e-posta ve şifren gerekecek.',
      confirmLabel: 'Çıkış yap',
      destructive: true,
    );
    if (!ok) return;
    navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
    await app.signOut();
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.label,
    required this.value,
    required this.placeholder,
    this.onTap,
    this.locked = false,
  });

  final String label;
  final String value;
  final String placeholder;
  final VoidCallback? onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final empty = value.isEmpty;
    return InkWell(
      onTap: locked ? null : onTap,
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppText.b(12, color: AppColors.muted)),
                  const SizedBox(height: 2),
                  Text(
                    empty ? placeholder : value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.b(15, color: empty || locked ? AppColors.grey : AppColors.ink),
                  ),
                ],
              ),
            ),
            Icon(
              locked ? Icons.lock_outline_rounded : Icons.edit_outlined,
              size: 18,
              color: locked ? AppColors.grey : AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.label, required this.value, required this.onChanged});
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppText.b(15, weight: FontWeight.w500))),
          AppToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Şifre değiştirme sayfası.
class _PasswordSheet extends StatefulWidget {
  const _PasswordSheet();

  @override
  State<_PasswordSheet> createState() => _PasswordSheetState();
}

class _PasswordSheetState extends State<_PasswordSheet> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _again = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _again.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_next.text.length < 6) {
      setState(() => _error = 'Yeni şifre en az 6 karakter olmalı.');
      return;
    }
    if (_next.text != _again.text) {
      setState(() => _error = 'Yeni şifreler aynı değil.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final app = AppScope.read(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await app.changePassword(current: _current.text, next: _next.text);
      navigator.pop();
      showToastOn(messenger, 'Şifren değişti.');
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetHandle(),
          const SizedBox(height: 16),
          Text('Şifre değiştir', style: AppText.d(24, weight: FontWeight.w600)),
          const SizedBox(height: 14),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(controller: _current, hint: 'Şu anki şifren', obscure: true, autofocus: true),
                  const SizedBox(height: 10),
                  AppTextField(controller: _next, hint: 'Yeni şifre (en az 6 karakter)', obscure: true),
                  const SizedBox(height: 10),
                  AppTextField(
                    controller: _again,
                    hint: 'Yeni şifre tekrar',
                    obscure: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _save(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!, style: AppText.b(14, weight: FontWeight.w600, color: AppColors.tomato)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(label: 'Şifreyi değiştir', busy: _busy, onTap: _save),
        ],
      ),
    );
  }
}
