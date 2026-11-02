import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Ekranlarda tekrar eden küçük parçalar: butonlar, kartlar, alanlar,
// alttan açılan sayfa ve kısa bildirim (toast).

/// Aralarına boşluk koyar (Column için).
List<Widget> vgap(List<Widget> children, double gap) {
  final out = <Widget>[];
  for (var i = 0; i < children.length; i++) {
    if (i > 0) out.add(SizedBox(height: gap));
    out.add(children[i]);
  }
  return out;
}

/// Aralarına boşluk koyar (Row için).
List<Widget> hgap(List<Widget> children, double gap) {
  final out = <Widget>[];
  for (var i = 0; i < children.length; i++) {
    if (i > 0) out.add(SizedBox(width: gap));
    out.add(children[i]);
  }
  return out;
}

/// Beyaz, hap şeklinde buton ("‹ Projeler", "Düzenle").
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.icon,
    this.trailingIcon,
    this.onTap,
    this.background = Colors.white,
    this.foreground = AppColors.ink,
    this.height = 44,
  });

  final String label;
  final IconData? icon;
  final IconData? trailingIcon;
  final VoidCallback? onTap;
  final Color background;
  final Color foreground;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: height,
          padding: EdgeInsets.only(left: icon == null ? 16 : 12, right: trailingIcon == null ? 16 : 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 18, color: foreground), const SizedBox(width: 6)],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.b(14, weight: FontWeight.w600, color: foreground),
                ),
              ),
              if (trailingIcon != null) ...[const SizedBox(width: 4), Icon(trailingIcon, size: 18, color: foreground)],
            ],
          ),
        ),
      ),
    );
  }
}

/// Yuvarlak ikon butonu (geri, ara, kapat).
class CircleButton extends StatelessWidget {
  const CircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 44,
    this.background = Colors.white,
    this.foreground = AppColors.ink,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color background;
  final Color foreground;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: size * 0.46, color: foreground),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

/// Seçilebilir hap ("Herkes", "Cuma", "17.00").
class ChoicePill extends StatelessWidget {
  const ChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.background = AppColors.paper,
    this.horizontalPadding = 14,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color background;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.ink;
    return Material(
      color: selected ? AppColors.ink : background,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: 44,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 16, color: fg), const SizedBox(width: 6)],
              Text(
                label,
                style: AppText.b(14, weight: selected ? FontWeight.w600 : FontWeight.w500, color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Büyük ana buton ("Giriş yap →", "İşi ekle →").
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.background = AppColors.lime,
    this.foreground = AppColors.ink,
    this.arrowColor,
    this.busy = false,
  });

  final String label;

  /// null ise buton pasif görünür.
  final VoidCallback? onTap;
  final Color background;
  final Color foreground;
  final Color? arrowColor;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !busy;
    final bg = enabled || busy ? background : AppColors.line2;
    final fg = enabled || busy ? foreground : AppColors.grey;
    return Material(
      color: bg,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: enabled ? onTap : null,
        child: SizedBox(
          height: 56,
          child: Center(
            child: busy
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label, style: AppText.b(16, weight: FontWeight.w700, color: fg)),
                      const SizedBox(width: 10),
                      Icon(Icons.arrow_forward_rounded, size: 20, color: enabled ? (arrowColor ?? fg) : fg),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Altı çizili metin bağlantısı ("Proje bilgisi", "Hepsini okudum").
class LinkText extends StatelessWidget {
  const LinkText(this.label, {super.key, required this.onTap, this.color = AppColors.ink, this.size = 14});

  final String label;
  final VoidCallback? onTap;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
        child: Text(
          label,
          style: AppText.b(size, weight: FontWeight.w600, color: color).copyWith(
            decoration: TextDecoration.underline,
            decorationColor: color,
          ),
        ),
      ),
    );
  }
}

/// Küçük etiket ("Üyesin", "İzleyicisin", "2 gün gecikti").
class Tag extends StatelessWidget {
  const Tag({
    super.key,
    required this.label,
    this.background = AppColors.lime,
    this.foreground = AppColors.ink,
    this.icon,
    this.radius = 12,
    this.fontSize = 12,
    this.weight = FontWeight.w700,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;
  final double radius;
  final double fontSize;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(radius)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: foreground), const SizedBox(width: 5)],
          Text(label, style: AppText.b(fontSize, weight: weight, color: foreground)),
        ],
      ),
    );
  }
}

/// Gecikme etiketi.
class OverdueTag extends StatelessWidget {
  const OverdueTag(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Tag(
      label: label,
      background: AppColors.tomatoLight,
      foreground: AppColors.tomato,
      radius: 8,
      fontSize: 13,
      weight: FontWeight.w600,
    );
  }
}

/// Beyaz, köşeleri yuvarlak bölüm kartı (Proje bilgisi, Profil, Ekip).
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    this.title,
    this.trailing,
    required this.children,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(18),
    this.gap = 10,
  });

  final String? title;
  final Widget? trailing;
  final List<Widget> children;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: vgap([
          if (title != null)
            Row(
              children: [
                Expanded(child: Text(title!, style: AppText.d(17, weight: FontWeight.w600, spacing: -0.2))),
                if (trailing != null) trailing!,
              ],
            ),
          ...children,
        ], gap),
      ),
    );
  }
}

/// Liste satırları arasındaki ince çizgi.
class RowDivider extends StatelessWidget {
  const RowDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: AppColors.line);
  }
}

/// İkonlu kısa açıklama satırı (sayfa altlarındaki gri notlar).
class InfoNote extends StatelessWidget {
  const InfoNote(this.text, {super.key, this.icon = Icons.info_outline_rounded});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 16, color: AppColors.muted),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: AppText.b(13, color: AppColors.muted, height: 1.45))),
      ],
    );
  }
}

/// Kırmızımsı uyarı kutusu.
class WarningBox extends StatelessWidget {
  const WarningBox(this.text, {super.key, this.icon = Icons.vpn_key_outlined});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColors.tomatoLight, borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.tomato),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppText.b(13, color: AppColors.tomato, height: 1.45))),
        ],
      ),
    );
  }
}

/// Gri zeminli metin alanı.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.suffix,
    this.autofocus = false,
    this.maxLines = 1,
    this.fill = AppColors.paper,
    this.textColor = AppColors.ink,
    this.hintColor = AppColors.muted,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;
  final bool autofocus;
  final int? maxLines;
  final Color fill;
  final Color textColor;
  final Color hintColor;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: width),
        );
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      autofocus: autofocus,
      maxLines: obscure ? 1 : maxLines,
      autofillHints: autofillHints,
      style: AppText.b(16, color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppText.b(16, color: hintColor),
        filled: true,
        fillColor: fill,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        suffixIcon: suffix,
        border: border(Colors.transparent, 0),
        enabledBorder: border(Colors.transparent, 0),
        focusedBorder: border(textColor, 2),
      ),
    );
  }
}

/// Açma-kapama düğmesi (tasarımdaki yeşil anahtar).
class AppToggle extends StatelessWidget {
  const AppToggle({super.key, required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      button: true,
      child: GestureDetector(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 50,
          height: 30,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value ? AppColors.forest : AppColors.outline,
            borderRadius: BorderRadius.circular(15),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 160),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? AppColors.lime : Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Alttan açılan sayfaların gri tutamacı.
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        decoration: BoxDecoration(color: AppColors.handle, borderRadius: BorderRadius.circular(3)),
      ),
    );
  }
}

/// Alttan açılan sayfa: beyaz, üst köşeleri yuvarlak, klavyeye göre kayar.
class SheetBody extends StatelessWidget {
  const SheetBody({super.key, required this.child, this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 20)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.92),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: padding.copyWith(bottom: padding.bottom + media.padding.bottom),
        child: child,
      ),
    );
  }
}

Future<T?> showAppSheet<T>(BuildContext context, WidgetBuilder builder) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    elevation: 0,
    builder: builder,
  );
}

/// Ekranın altında kısa bir mesaj gösterir (alt menünün üstünde).
void showToast(BuildContext context, String message) {
  showToastOn(ScaffoldMessenger.of(context), message);
}

void showToastOn(ScaffoldMessengerState messenger, String message) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      duration: const Duration(seconds: 3),
    ));
}

/// Evet/hayır sorusu.
Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(title, style: AppText.d(22, weight: FontWeight.w600)),
      content: Text(message, style: AppText.b(15, color: AppColors.text2, height: 1.45)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Vazgeç', style: AppText.b(15, weight: FontWeight.w600)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            confirmLabel,
            style: AppText.b(15, weight: FontWeight.w700, color: destructive ? AppColors.tomato : AppColors.forest),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Tek satırlık metin soran pencere. Vazgeçilirse null döner.
Future<String?> askText(
  BuildContext context, {
  required String title,
  String initial = '',
  String? hint,
  TextInputType? keyboardType,
  String confirmLabel = 'Kaydet',
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _TextPrompt(
      title: title,
      initial: initial,
      hint: hint,
      keyboardType: keyboardType,
      confirmLabel: confirmLabel,
    ),
  );
}

class _TextPrompt extends StatefulWidget {
  const _TextPrompt({
    required this.title,
    required this.initial,
    required this.hint,
    required this.keyboardType,
    required this.confirmLabel,
  });

  final String title;
  final String initial;
  final String? hint;
  final TextInputType? keyboardType;
  final String confirmLabel;

  @override
  State<_TextPrompt> createState() => _TextPromptState();
}

class _TextPromptState extends State<_TextPrompt> {
  late final TextEditingController _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(widget.title, style: AppText.d(22, weight: FontWeight.w600)),
      content: AppTextField(
        controller: _controller,
        hint: widget.hint,
        autofocus: true,
        keyboardType: widget.keyboardType,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Vazgeç', style: AppText.b(15, weight: FontWeight.w600)),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(widget.confirmLabel, style: AppText.b(15, weight: FontWeight.w700, color: AppColors.forest)),
        ),
      ],
    );
  }
}
