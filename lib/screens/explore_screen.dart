import 'package:flutter/material.dart';

import '../models/character.dart';
import '../theme/app_colors.dart';
import '../widgets/character_widgets.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({
    required this.characters,
    required this.isLoading,
    required this.loadError,
    required this.searchController,
    required this.filter,
    required this.favorites,
    required this.nextPage,
    required this.isLoadingMore,
    required this.onSearch,
    required this.onFilterSelected,
    required this.onFavoriteToggle,
    required this.onCharacterTap,
    required this.onLogout,
    required this.onLoadMore,
    required this.onRetry,
    super.key,
  });

  final List<Character> characters;
  final bool isLoading;
  final Object? loadError;
  final TextEditingController searchController;
  final String filter;
  final Set<int> favorites;
  final int? nextPage;
  final bool isLoadingMore;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onFilterSelected;
  final ValueChanged<Character> onFavoriteToggle;
  final ValueChanged<Character> onCharacterTap;
  final VoidCallback onLogout;
  final VoidCallback onLoadMore;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      children: [
        BrandHeader(onLogout: onLogout),
        const SizedBox(height: 28),
        const Text(
          'Explore',
          style: TextStyle(
            color: AppColors.olive,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Meet the residents of every dimension.',
          style: mutedTextStyle,
        ),
        const SizedBox(height: 20),
        CharacterSearchField(
          controller: searchController,
          onSearch: onSearch,
        ),
        const SizedBox(height: 15),
        CharacterFilterRow(selected: filter, onSelected: onFilterSelected),
        const SizedBox(height: 20),
        SectionTitle(
          title: searchController.text.isEmpty
              ? 'All Characters'
              : 'Results for "${searchController.text}"',
          trailing: '${characters.length}',
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const LoadingCard(height: 220)
        else if (loadError != null)
          ErrorCard(error: loadError!, onRetry: onRetry)
        else if (characters.isEmpty)
          const EmptyCard(
            message: 'No characters found. Try another search.',
          )
        else
          ...characters.map(
            (character) => CharacterListCard(
              character: character,
              isFavorite: favorites.contains(character.id),
              onTap: () => onCharacterTap(character),
              onFavoriteTap: () => onFavoriteToggle(character),
            ),
          ),
        if (!isLoading && loadError == null && nextPage != null) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: isLoadingMore ? null : onLoadMore,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.olive,
              side: const BorderSide(color: AppColors.line),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: isLoadingMore
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Load more characters'),
          ),
        ],
      ],
    );
  }
}
