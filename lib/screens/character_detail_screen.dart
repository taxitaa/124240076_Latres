import 'package:flutter/material.dart';

import '../models/character.dart';
import '../theme/app_colors.dart';
import '../widgets/character_widgets.dart';

class CharacterDetailScreen extends StatefulWidget {
  const CharacterDetailScreen({
    required this.character,
    required this.isFavorite,
    required this.onFavoritePressed,
    super.key,
  });

  final Character character;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;

  @override
  State<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final character = widget.character;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 355,
            pinned: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(7),
              child: RoundIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(7),
                child: FavoriteButton(
                  selected: _isFavorite,
                  onTap: _toggleFavorite,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CharacterImage(url: character.image),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xB8000000)],
                            stops: [0.55, 1],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        right: 18,
                        bottom: 22,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CharacterPill('CHARACTER #${character.id}'),
                            const SizedBox(height: 9),
                            Text(
                              character.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 27,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 19, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusDot(status: character.status),
                      const SizedBox(width: 6),
                      Text(
                        character.status,
                        style: const TextStyle(
                          color: AppColors.olive,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        '· ${character.species}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 19),
                  Row(
                    children: [
                      FactCard(
                        label: 'Gender',
                        value: character.gender,
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(width: 9),
                      FactCard(
                        label: 'Episodes',
                        value: '${character.episodeCount}',
                        icon: Icons.movie_outlined,
                      ),
                      const SizedBox(width: 9),
                      FactCard(
                        label: 'ID',
                        value: '#${character.id}',
                        icon: Icons.tag_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'About Character',
                    style: TextStyle(
                      color: AppColors.olive,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CharacterInfoTile(
                    icon: Icons.public_rounded,
                    label: 'Origin',
                    value: character.origin,
                  ),
                  const SizedBox(height: 9),
                  CharacterInfoTile(
                    icon: Icons.place_outlined,
                    label: 'Last known location',
                    value: character.location,
                  ),
                  if (character.type.isNotEmpty) ...[
                    const SizedBox(height: 9),
                    CharacterInfoTile(
                      icon: Icons.category_outlined,
                      label: 'Type',
                      value: character.type,
                    ),
                  ],
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _toggleFavorite,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.olive,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      icon: Icon(
                        _isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 18,
                      ),
                      label: Text(
                        _isFavorite ? 'Saved to Favorites' : 'Save Character',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite() {
    widget.onFavoritePressed();
    final wasFavorite = _isFavorite;
    setState(() => _isFavorite = !wasFavorite);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            wasFavorite
                ? '${widget.character.name} removed from favorites'
                : '${widget.character.name} added to favorites',
          ),
        ),
      );
  }
}
