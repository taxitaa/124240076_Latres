import 'package:flutter/material.dart';

import '../models/character.dart';
import '../theme/app_colors.dart';
import '../widgets/character_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.username,
    required this.characters,
    required this.isLoading,
    required this.loadError,
    required this.selectedStatus,
    required this.favorites,
    required this.onFavoriteToggle,
    required this.onCharacterTap,
    required this.onLogout,
    required this.onStatusSelected,
    required this.onViewAll,
    required this.onRetry,
    super.key,
  });

  final String username;
  final List<Character> characters;
  final bool isLoading;
  final Object? loadError;
  final String selectedStatus;
  final Set<int> favorites;
  final ValueChanged<Character> onFavoriteToggle;
  final ValueChanged<Character> onCharacterTap;
  final VoidCallback onLogout;
  final ValueChanged<String> onStatusSelected;
  final VoidCallback onViewAll;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
      children: [
        BrandHeader(onLogout: onLogout),
        const SizedBox(height: 27),
        Text(
          'Hi, $username 👋',
          style: TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        const SizedBox(height: 5),
        const Text(
          'Find your next\nfavorite character',
          style: TextStyle(
            color: AppColors.olive,
            fontSize: 27,
            height: 1.15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.7,
          ),
        ),
        const SizedBox(height: 18),
        CharacterFilterRow(
          selected: selectedStatus,
          onSelected: onStatusSelected,
        ),
        const SizedBox(height: 18),
        SectionTitle(
          title: selectedStatus == 'All'
              ? 'Featured Character'
              : '$selectedStatus Characters',
          trailing: '${characters.length}',
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const LoadingCard(height: 264)
        else if (loadError != null)
          ErrorCard(error: loadError!, onRetry: onRetry)
        else if (characters.isEmpty)
          const EmptyCard(message: 'No characters found with this status.')
        else
          FeaturedCharacterCard(
            character: characters.first,
            isFavorite: favorites.contains(characters.first.id),
            onTap: () => onCharacterTap(characters.first),
            onFavoriteTap: () => onFavoriteToggle(characters.first),
          ),
        const SizedBox(height: 25),
        if (!isLoading && loadError == null && characters.length > 1) ...[
          SectionTitle(
            title: 'More Characters',
            trailing: 'View all',
            onTrailing: onViewAll,
          ),
          const SizedBox(height: 13),
          SizedBox(
            height: 176,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: characters.length - 1,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final character = characters[index + 1];
                return SmallCharacterCard(
                  character: character,
                  isFavorite: favorites.contains(character.id),
                  onTap: () => onCharacterTap(character),
                  onFavoriteTap: () => onFavoriteToggle(character),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
