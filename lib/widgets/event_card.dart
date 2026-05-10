import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../utils/app_colors.dart';
import '../utils/text_styles.dart';

class EventCard extends StatefulWidget {
  final Event event;
  final int idx;
  final VoidCallback onTap;
  final VoidCallback onSave;
  final int interestedCount;
  final bool showAdminActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EventCard({
    super.key,
    required this.event,
    required this.idx,
    required this.onTap,
    required this.onSave,
    required this.interestedCount,
    this.showAdminActions = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool _hovered = false;

  static const List<double> _rots = [-0.7, 0.4, -0.3, 0.6, -0.5, 0.3];

  IconData _catIcon(String cat) {
    switch (cat) {
      case 'Academic':
        return Icons.menu_book_outlined;
      case 'Social':
        return Icons.people_outlined;
      case 'Sports':
        return Icons.sports_basketball_outlined;
      case 'Career':
        return Icons.work_outline;
      case 'Arts':
        return Icons.palette_outlined;
      default:
        return Icons.event_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.postit[widget.idx % AppColors.postit.length];
    final rot = _rots[widget.idx % 6];

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) => setState(() => _hovered = false),
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..rotateZ((_hovered ? 0 : rot) * 0.0174533)
          ..scale(_hovered ? 1.02 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: c.bg,
          border: Border.all(color: c.border),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(_hovered ? 0.4 : 0.25),
                blurRadius: _hovered ? 24 : 10,
                offset: const Offset(0, 3))
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -4,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: c.pin,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: c.pin.withOpacity(0.6), blurRadius: 4)
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_catIcon(widget.event.cat), color: c.pin, size: 11),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(widget.event.cat.toUpperCase(),
                            style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: c.pin,
                                letterSpacing: 0.08)),
                      ),
                      GestureDetector(
                        onTap: widget.onSave,
                        child: Icon(
                          widget.event.saved
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: widget.event.saved ? c.pin : AppColors.textDim,
                          size: 13,
                        ),
                      ),
                    ],
                  ),
                  if (widget.showAdminActions) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _AdminMiniButton(
                            icon: Icons.edit_outlined,
                            color: AppColors.textSec,
                            borderColor: AppColors.border,
                            onTap: widget.onEdit),
                        const SizedBox(width: 6),
                        _AdminMiniButton(
                            icon: Icons.delete_outline,
                            color: AppColors.danger,
                            borderColor: AppColors.danger.withOpacity(0.25),
                            fillColor: AppColors.dangerFaded,
                            onTap: widget.onDelete),
                      ],
                    ),
                  ],
                  if (widget.event.posterUrl != null) ...[
                    const SizedBox(height: 10),
                    Flexible(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 80),
                          child: widget.event.posterUrl!.startsWith('assets/')
                              ? Image.asset(widget.event.posterUrl!,
                                  width: double.infinity, fit: BoxFit.cover)
                              : Image.network(
                                  widget.event.posterUrl!,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: AppColors.surfaceAlt,
                                    alignment: Alignment.center,
                                    child: Icon(Icons.image_outlined,
                                        color: c.pin, size: 18),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(widget.event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(12,
                              color: c.cardText, weight: FontWeight.w600)
                          .copyWith(height: 1.35, letterSpacing: -0.01)),
                  const SizedBox(height: 3),
                  Text(widget.event.club,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption(
                          color: AppColors.textSec, size: 10)),
                  const SizedBox(height: 4),
                  Text(
                    'Location: ${widget.event.loc}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(
                        color: AppColors.textSec, size: 9),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 9, color: AppColors.textDim),
                      const SizedBox(width: 2),
                      Text(widget.event.date,
                          style: AppTextStyles.caption(size: 9)),
                      const SizedBox(width: 8),
                      Icon(Icons.access_time,
                          size: 9, color: AppColors.textDim),
                      const SizedBox(width: 2),
                      Text(widget.event.time,
                          style: AppTextStyles.caption(size: 9)),
                    ],
                  ),
                  if (widget.interestedCount > 0) ...[
                    Divider(color: c.border, thickness: 1, height: 16),
                    Row(
                      children: [
                        Icon(Icons.people_outline,
                            size: 9, color: AppColors.textDim),
                        const SizedBox(width: 3),
                        Text('${widget.interestedCount} interested',
                            style: AppTextStyles.caption(size: 9)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminMiniButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color borderColor;
  final Color? fillColor;
  final VoidCallback? onTap;
  const _AdminMiniButton(
      {required this.icon,
      required this.color,
      required this.borderColor,
      this.fillColor,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: fillColor ?? AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: borderColor),
        ),
        child: Icon(icon, size: 13, color: color),
      ),
    );
  }
}
