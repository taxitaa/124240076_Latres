import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/character_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    required this.favoriteCount,
    super.key,
  });

  final int favoriteCount;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      children: [
        const BrandHeader(),
        const SizedBox(height: 28),
        const Text(
          'About this app',
          style: TextStyle(
            color: AppColors.olive,
            fontSize: 27,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.public_rounded,
                color: AppColors.olive,
                size: 26,
              ),
              const SizedBox(height: 12),
              const Text(
                'The Multiverse Directory',
                style: TextStyle(
                  color: AppColors.olive,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Discover characters from Rick and Morty. Character details are '
                'provided by the Rick and Morty API.',
                style: mutedTextStyle.copyWith(height: 1.5),
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.line),
              const SizedBox(height: 8),
              const Text(
                'API  ·  rickandmortyapi.com',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ProfileInfoTile(
          icon: Icons.favorite_outline_rounded,
          title: 'Saved characters',
          subtitle: '$favoriteCount characters',
        ),
        const ProfileInfoTile(
          icon: Icons.language_rounded,
          title: 'Universe',
          subtitle: 'C-137 and beyond',
        ),
      ],
    );
  }
}
