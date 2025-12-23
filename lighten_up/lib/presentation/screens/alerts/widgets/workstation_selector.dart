import 'package:flutter/material.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';
import 'package:lighten_up/data/models/workstation.dart';

/// Workstation selector component for the alert settings screen
/// Displays a searchable list of workstations with radio selection
class WorkstationSelector extends StatefulWidget {
  final List<Workstation> workstations;
  final String? selectedWorkstationId;
  final ValueChanged<String?> onWorkstationSelected;

  const WorkstationSelector({
    super.key,
    required this.workstations,
    this.selectedWorkstationId,
    required this.onWorkstationSelected,
  });

  @override
  State<WorkstationSelector> createState() => _WorkstationSelectorState();
}

class _WorkstationSelectorState extends State<WorkstationSelector> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredWorkstations = widget.workstations
        .where(
          (ws) => ws.name.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();

    return Container(
      width: 320,
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchBar(),
          const SizedBox(height: AppDimensions.spaceMd),
          Expanded(child: _buildWorkstationList(filteredWorkstations)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) {
        setState(() {
          searchQuery = value;
        });
      },
      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search workstations...',
        hintStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildWorkstationList(List<Workstation> workstations) {
    return ListView.separated(
      itemCount: workstations.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppDimensions.spaceSm),
      itemBuilder: (context, index) {
        final workstation = workstations[index];
        final isSelected = workstation.id == widget.selectedWorkstationId;
        final isActive = workstation.status == WorkstationStatus.active;

        return _WorkstationCard(
          workstation: workstation,
          isSelected: isSelected,
          isActive: isActive,
          onTap: () => widget.onWorkstationSelected(workstation.id),
        );
      },
    );
  }
}

class _WorkstationCard extends StatelessWidget {
  final Workstation workstation;
  final bool isSelected;
  final bool isActive;
  final VoidCallback onTap;

  const _WorkstationCard({
    required this.workstation,
    required this.isSelected,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Radio<String>(
              value: workstation.id,
              groupValue: isSelected ? workstation.id : null,
              onChanged: (_) => onTap(),
              activeColor: AppColors.primary,
            ),
            const SizedBox(width: AppDimensions.spaceSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          workstation.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.successGreen
                              : AppColors.textSecondary,
                          shape: BoxShape.circle,
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: AppColors.successGreen.withValues(
                                      alpha: 0.6,
                                    ),
                                    blurRadius: 8,
                                    spreadRadius: 0,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${workstation.zone} • ${isActive ? 'Active' : 'Offline'}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
