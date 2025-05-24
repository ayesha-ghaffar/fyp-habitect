import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  final String iconName;
  final double size;
  final Color? color;

  const SvgIcon({
    super.key,
    required this.iconName,
    this.size = 26,
    this.color = Colors.black87,
  });

  String getIconPath(String iconName) {
    switch (iconName) {
      case 'active': return 'assets/icons/active.svg';
      case 'add': return 'assets/icons/add.svg';
      case 'arrow-right': return 'assets/icons/right.svg';
      case 'bookmark': return 'assets/icons/bookmark.svg';
      case 'bookmark-fill': return 'assets/icons/bookmark-fill.svg';
      case 'building': return 'assets/icons/business.svg';
      case 'calendar': return 'assets/icons/calendar.svg';
      case 'close': return 'assets/icons/close.svg';
      case 'file-list': return 'assets/icons/files.svg';
      case 'filter-list': return 'assets/icons/filter-list.svg';
      case 'gallery': return 'assets/icons/gallery.svg';
      case 'home': return 'assets/icons/home.svg';
      case 'location': return 'assets/icons/location.svg';
      case 'menu': return 'assets/icons/menu.svg';
      case 'message': return 'assets/icons/messages.svg';
      case 'money-dollar': return 'assets/icons/money.svg';
      case 'notification': return 'assets/icons/notifications.svg';
      case 'schedule': return 'assets/icons/schedule.svg';
      case 'search': return 'assets/icons/search.svg';
      case 'star': return 'assets/icons/star.svg';
      case 'tree': return 'assets/icons/tree.svg';
      case 'user': return 'assets/icons/profile.svg';
      default: return 'assets/icons/circle.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? IconTheme.of(context).color;
    return SvgPicture.asset(
      getIconPath(iconName),
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}
