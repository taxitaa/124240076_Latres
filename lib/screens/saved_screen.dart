import 'package:flutter/material.dart';

import '../models/character.dart';
import '../theme/app_colors.dart';
import '../widgets/character_widgets.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({
    required this.characters,
    required this.favorites,
    required this.onCharacterTap,
    required this.onFavoriteToggle,
    required this.onLogout,
    super.key,
  });

  final List<Character> characters;
  final Set<int> favorites;
  final ValueChanged<Character> onCharacterTap;
  final ValueChanged<Character> onFavoriteToggle;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final savedCharacters = characters
        .where((character) => favorites.contains(character.id))
        .toList(growable: false);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      children: [
        BrandHeader(onLogout: onLogout),
        const SizedBox(height: 28),
        const Text(
          'Saved Characters',
          style: TextStyle(
            color: AppColors.olive,
            fontSize: 27,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Your favorite faces across the multiverse.',
          style: mutedTextStyle,
        ),
        const SizedBox(height: 20),
        if (savedCharacters.isEmpty)
          const EmptyCard(
            message:
                'No saved characters yet. Tap the heart on a character to save it.',
          )
        else
          ...savedCharacters.map(
            (character) => Dismissible(
              key: ValueKey<int>(character.id),
              direction: DismissDirection.endToStart,
              background: Container(
                margin: const EdgeInsets.only(bottom: 11),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 22),
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(19),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
              onDismissed: (_) {
                onFavoriteToggle(character);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${character.name} dihapus dari favorit')),
                );
              },
              child: CharacterListCard(
                character: character,
                isFavorite: true,
                onTap: () => onCharacterTap(character),
                onFavoriteTap: () {
                  onFavoriteToggle(character);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${character.name} dihapus dari favorit')),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
