import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/models.dart';
import '../state/app_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'home_shell.dart';

/// Giriş ekranı. Kayıt ekranı yok; kişiyi yönetici davet eder.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidden = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'E-posta ve şifreni yaz.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await AppScope.read(context).signIn(email, password);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const HomeShell()),
      );
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Bağlanılamadı. İnternetini kontrol edip tekrar dene.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _forgot() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Önce e-posta adresini yaz, sıfırlama bağlantısını oraya gönderelim.');
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    await AppScope.read(context).repository.requestPasswordReset(email);
    showToastOn(messenger, 'Şifre sıfırlama bağlantısı e-postana gönderildi.');
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.forest,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final topHeight = math.max(250.0, constraints.maxHeight - 492);
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: topHeight,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Logodaki üç sütun
                        _bar(right: 130, height: 150, color: AppColors.lime),
                        _bar(right: 66, height: 230, color: AppColors.paper),
                        _bar(right: 2, height: 318, color: AppColors.pine),
                        Positioned(
                          left: 24,
                          top: topInset + 20,
                          width: 190,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GörevAkış',
                                style: AppText.d(38, weight: FontWeight.w800, color: Colors.white, spacing: -1.1, height: 1),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Ekibin işleri tek yerde. Kimde ne var, herkes görür.',
                                style: AppText.b(16, color: AppColors.sage, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(minHeight: math.max(0.0, constraints.maxHeight - topHeight)),
                    padding: EdgeInsets.fromLTRB(22, 28, 22, 26 + MediaQuery.of(context).padding.bottom),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Tekrar hoş geldin', style: AppText.d(29, height: 1.1)),
                          const SizedBox(height: 18),
                          _label('E-posta'),
                          AppTextField(
                            controller: _email,
                            hint: 'e-posta adresin',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                          ),
                          const SizedBox(height: 16),
                          _label('Şifre'),
                          AppTextField(
                            controller: _password,
                            hint: 'şifren',
                            obscure: _hidden,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _signIn(),
                            autofillHints: const [AutofillHints.password],
                            suffix: IconButton(
                              tooltip: _hidden ? 'Şifreyi göster' : 'Şifreyi gizle',
                              onPressed: () => setState(() => _hidden = !_hidden),
                              icon: Icon(
                                _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: LinkText('Şifremi unuttum', onTap: _busy ? null : _forgot),
                          ),
                          if (_error != null) ...[
                            Text(_error!, style: AppText.b(14, weight: FontWeight.w600, color: AppColors.tomato)),
                            const SizedBox(height: 10),
                          ] else
                            const SizedBox(height: 6),
                          PrimaryButton(label: 'Giriş yap', busy: _busy, onTap: _signIn),
                          const SizedBox(height: 28),
                          Text(
                            'Davet e-postası geldiyse oradaki bağlantıyla katıl.',
                            textAlign: TextAlign.center,
                            style: AppText.b(13, color: AppColors.muted, height: 1.45),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.muted),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Veriler AhsaTech sunucusunda kalır',
                                  textAlign: TextAlign.center,
                                  style: AppText.b(13, color: AppColors.muted),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _bar({required double right, required double height, required Color color}) {
    return Positioned(
      right: right,
      bottom: -14,
      width: 54,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(27)),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(text, style: AppText.b(14, weight: FontWeight.w600)),
    );
  }
}
