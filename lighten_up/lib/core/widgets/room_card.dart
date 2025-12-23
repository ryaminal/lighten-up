import 'package:flutter/material.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';
import 'package:lighten_up/core/widgets/room_card/room_light_button.dart';
import 'package:lighten_up/core/widgets/room_card/room_status_badge.dart';
import 'package:lighten_up/data/models/room.dart';

/// Room card widget displaying room status and alert lights
class RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback? onTap;
  final Function(RoomLight)? onLightTap;

  const RoomCard({super.key, required this.room, this.onTap, this.onLightTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.borderDark, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_buildHeader(), _buildLightsList()],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMd,
        vertical: AppDimensions.spaceSm,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF233648),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.radiusLg),
          topRight: Radius.circular(AppDimensions.radiusLg),
        ),
        border: Border(bottom: BorderSide(color: Color(0xFF2d4256), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              room.displayLabel,
              style: AppTextStyles.headingSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          RoomStatusBadge(status: room.status),
        ],
      ),
    );
  }

  Widget _buildLightsList() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spaceSm),
        child: Column(
          children: room.lights.map((light) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.space2xs),
              child: RoomLightButton(
                light: light,
                onTap: onLightTap != null ? () => onLightTap!(light) : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
