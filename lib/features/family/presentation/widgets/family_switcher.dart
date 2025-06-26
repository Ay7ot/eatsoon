import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eat_soon/features/auth/providers/auth_provider.dart';
import 'package:eat_soon/features/family/data/models/family_model.dart';
import 'package:eat_soon/features/family/data/services/family_service.dart';

/// A reusable widget that lets the user switch between the families they
/// belong to.  If the user has only one (or zero) families, it simply shows
/// the current family name (or nothing).
///
/// The widget relies entirely on [AuthProvider] for state and calls
/// `AuthProvider.switchFamily()` when the user selects a new family.
class FamilySwitcher extends StatefulWidget {
  const FamilySwitcher({super.key});

  @override
  State<FamilySwitcher> createState() => _FamilySwitcherState();
}

class _FamilySwitcherState extends State<FamilySwitcher> {
  final FamilyService _familyService = FamilyService();

  Future<List<FamilyModel>> _fetchFamilies(AuthProvider provider) async {
    final ids = provider.familyIds;
    final results = await Future.wait(ids.map(_familyService.getFamily));
    return results.whereType<FamilyModel>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final familyIds = auth.familyIds;
        final currentId = auth.currentFamilyId;

        // If the user has no family, render nothing.
        if (familyIds.isEmpty) {
          return const SizedBox.shrink();
        }

        return FutureBuilder<List<FamilyModel>>(
          future: _fetchFamilies(auth),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            }

            final families = snapshot.data!;
            final currentFamily = families.firstWhere(
              (f) => f.id == currentId,
              orElse: () => families.first,
            );

            // If only one family, just display its name (no interaction)
            if (familyIds.length == 1) {
              return Text(
                currentFamily.name,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF111827),
                ),
              );
            }

            // Multiple families -> tap to change
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final selected = await showModalBottomSheet<String>(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder:
                      (_) => _FamilySelectionSheet(
                        families: families,
                        currentFamilyId: currentId,
                      ),
                );
                if (selected != null && selected != currentId) {
                  await auth.switchFamily(selected);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentFamily.name,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _FamilySelectionSheet extends StatelessWidget {
  final List<FamilyModel> families;
  final String? currentFamilyId;

  const _FamilySelectionSheet({
    Key? key,
    required this.families,
    required this.currentFamilyId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Header
            const Text(
              'Choose a Family',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Switch between the families you belong to.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: families.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final f = families[index];
                  return RadioListTile<String>(
                    value: f.id,
                    groupValue: currentFamilyId,
                    onChanged: (val) => Navigator.pop(context, val),
                    activeColor: const Color(0xFF10B981),
                    title: Text(
                      f.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
