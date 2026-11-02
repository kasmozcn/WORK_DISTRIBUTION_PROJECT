import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme/app_theme.dart';

/// Baş harfli yuvarlak avatar. [user] null ise boş (sahipsiz) görünür.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.user,
    this.size = 40,
    this.selected = false,
    this.borderColor,
  });

  final AppUser? user;
  final double size;

  /// Seçiliyse etrafına koyu bir halka çizilir (filtre ve "Kime?" seçimi).
  final bool selected;

  /// Üst üste binen avatarlarda zemine göre ince kenar.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final u = user;
    final circle = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: u == null ? AppColors.tray : Color(u.colorValue),
        shape: BoxShape.circle,
        border: borderColor == null ? null : Border.all(color: borderColor!, width: 2),
      ),
      child: u == null
          ? Icon(Icons.person_outline_rounded, size: size * 0.5, color: AppColors.muted)
          : Text(
              u.initials,
              style: AppText.d(
                (size * 0.36).roundToDouble(),
                color: Colors.white,
                spacing: 0,
                height: 1,
              ),
            ),
    );
    if (!selected) return circle;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.ink, width: 2),
      ),
      child: circle,
    );
  }
}

/// Üst üste binen avatarlar (proje kartlarında).
class AvatarStack extends StatelessWidget {
  const AvatarStack({
    super.key,
    required this.users,
    this.size = 30,
    this.background = Colors.white,
  });

  final List<AppUser> users;
  final double size;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < users.length; i++)
          Align(
            alignment: Alignment.centerLeft,
            widthFactor: i == users.length - 1 ? 1 : 0.74,
            child: UserAvatar(user: users[i], size: size, borderColor: background),
          ),
      ],
    );
  }
}
