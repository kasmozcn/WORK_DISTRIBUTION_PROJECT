import 'package:flutter/material.dart';

import '../data/models.dart';
import '../state/app_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/common.dart';

/// Ekip: kişiler, roller ve (yöneticiye) davet.
class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final me = app.me;
    if (me == null) return const SizedBox.shrink();
    final people = List<AppUser>.of(app.users)
      ..sort((a, b) {
        if (a.isManager != b.isManager) return a.isManager ? -1 : 1;
        return a.fullName.compareTo(b.fullName);
      });

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.only(top: 14, bottom: AppBottomNav.reservedHeight(context)),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (app.isManager) ...[
                  const Tag(label: 'Yönetici görünümü', background: AppColors.forest, foreground: AppColors.lime),
                  const SizedBox(height: 12),
                ],
                Text('Ekip', style: AppText.d(38, height: 1.02, spacing: -0.95)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.muted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${people.length} kişi · Veriler AhsaTech sunucusunda',
                        style: AppText.b(14, color: AppColors.muted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: vgap([
                if (app.isManager) const _InviteCard(),
                SectionCard(
                  title: 'Kişiler',
                  gap: 0,
                  children: [
                    const SizedBox(height: 4),
                    for (var i = 0; i < people.length; i++) ...[
                      if (i > 0) const RowDivider(),
                      _PersonRow(user: people[i], isMe: people[i].id == me.id),
                    ],
                  ],
                ),
                SectionCard(
                  title: 'Kim neyi değiştirebilir?',
                  children: const [
                    _Bullet('Yönetici kişi ekler, projeye atar ve rol verir.'),
                    _Bullet('Üyeler atandıkları projede iş ekler, taşır ve yorum yazar.'),
                    _Bullet('Projeye atanmayan kişi o projeyi sadece izler.'),
                    _Bullet('Projeyi ve sütunları arşivlemeyi sadece yönetici yapar.'),
                  ],
                ),
              ], 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteCard extends StatefulWidget {
  const _InviteCard();

  @override
  State<_InviteCard> createState() => _InviteCardState();
}

class _InviteCardState extends State<_InviteCard> {
  final _email = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _invite() async {
    final email = _email.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    if (!email.contains('@') || !email.contains('.')) {
      showToastOn(messenger, 'Geçerli bir e-posta adresi yaz.');
      return;
    }
    setState(() => _busy = true);
    await AppScope.read(context).invite(email);
    if (!mounted) return;
    setState(() => _busy = false);
    _email.clear();
    FocusScope.of(context).unfocus();
    showToastOn(messenger, 'Davet gönderildi: $email');
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      color: AppColors.forest,
      gap: 12,
      children: [
        Text('Ekibe birini çağır', style: AppText.d(24, weight: FontWeight.w600, color: Colors.white)),
        Text(
          'Ekibe kişiyi sadece yönetici ekler. Davet edilen kişi e-postasındaki bağlantıyla katılır.',
          style: AppText.b(14, color: AppColors.sage, height: 1.45),
        ),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _email,
                hint: 'e-posta adresi',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _invite(),
                fill: AppColors.inputOnDark,
                textColor: Colors.white,
                hintColor: AppColors.sage,
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: AppColors.lime,
              shape: const StadiumBorder(),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: _busy ? null : _invite,
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  alignment: Alignment.center,
                  child: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink),
                        )
                      : Text('Davet et', style: AppText.b(15, weight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({required this.user, required this.isMe});
  final AppUser user;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final role = user.isManager ? 'Yönetici' : 'Üye';
    return InkWell(
      onTap: () => showAppSheet<void>(context, (_) => _PersonSheet(userId: user.id)),
      child: SizedBox(
        height: 62,
        child: Row(
          children: [
            UserAvatar(user: user, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isMe ? '${user.fullName} (sen)' : user.fullName, style: AppText.b(15, weight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (isMe) ...[
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(color: AppColors.online, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          isMe ? 'Şu an çevrimiçi · $role' : role,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.b(13, color: AppColors.muted),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
          ],
        ),
      ),
    );
  }
}

/// Kişiye dokununca açılır. Yönetici burada rol verir ve projeye atar.
class _PersonSheet extends StatelessWidget {
  const _PersonSheet({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final me = app.me;
    final user = app.userById(userId);
    if (user == null || me == null) return const SizedBox.shrink();
    final manager = app.isManager;
    final isSelf = user.id == me.id;
    final projects = app.activeProjects;

    return SheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetHandle(),
          const SizedBox(height: 16),
          Row(
            children: [
              UserAvatar(user: user, size: 50),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.fullName, style: AppText.d(22, weight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(user.email, style: AppText.b(14, color: AppColors.muted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text('Rol', style: AppText.b(13, weight: FontWeight.w600, color: AppColors.muted)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoicePill(
                label: 'Yönetici',
                selected: user.isManager,
                onTap: manager && !isSelf && !user.isManager ? () => app.setManager(user, true) : null,
              ),
              ChoicePill(
                label: 'Üye',
                selected: !user.isManager,
                onTap: manager && !isSelf && user.isManager ? () => app.setManager(user, false) : null,
              ),
            ],
          ),
          if (manager && isSelf) ...[
            const SizedBox(height: 8),
            const InfoNote('Kendi rolünü değiştiremezsin; başka bir yönetici değiştirebilir.'),
          ],
          const SizedBox(height: 18),
          Text('Projeler', style: AppText.b(13, weight: FontWeight.w600, color: AppColors.muted)),
          const SizedBox(height: 4),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final p in projects)
                  SizedBox(
                    height: 52,
                    child: Row(
                      children: [
                        Expanded(child: Text(p.name, style: AppText.b(15, weight: FontWeight.w500))),
                        if (manager)
                          AppToggle(
                            value: p.isMember(user.id),
                            onChanged: (v) => app.setMembership(p, user.id, v),
                          )
                        else
                          Text(
                            p.isMember(user.id) ? 'Üye' : 'İzleyici',
                            style: AppText.b(14, color: AppColors.muted),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (manager) ...[
            const SizedBox(height: 8),
            const InfoNote('Projeye atanmayan kişi o projeyi sadece izler.'),
          ],
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 8, right: 10),
          decoration: const BoxDecoration(color: AppColors.forest, shape: BoxShape.circle),
        ),
        Expanded(child: Text(text, style: AppText.b(14, color: AppColors.text2, height: 1.45))),
      ],
    );
  }
}
