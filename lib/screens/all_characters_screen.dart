import 'package:flutter/material.dart';

import '../models/character.dart';
import '../services/character_api.dart';
import '../theme/app_colors.dart';
import '../widgets/character_widgets.dart';

class AllCharactersResult {
  const AllCharactersResult({required this.characters, required this.nextPage});

  final List<Character> characters;
  final int? nextPage;
}

class AllCharactersScreen extends StatefulWidget {
  const AllCharactersScreen({
    required this.characters,
    required this.nextPage,
    required this.status,
    required this.favorites,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onCharacterTap,
    super.key,
  });

  final List<Character> characters;
  final int? nextPage;
  final String status;
  final Set<int> favorites;
  final bool Function(int) isFavorite;
  final ValueChanged<Character> onFavoriteToggle;
  final Future<void> Function(Character) onCharacterTap;

  @override
  State<AllCharactersScreen> createState() => _AllCharactersScreenState();
}

class _AllCharactersScreenState extends State<AllCharactersScreen> {
  final _api = CharacterApi();
  final _scrollController = ScrollController();
  late final List<Character> _characters;
  late final Set<int> _favorites;
  late int? _nextPage;
  Object? _loadError;
  bool _isLoadingMore = false;

  List<Character> get _filteredCharacters {
    if (widget.status == 'All') return _characters;
    return _characters
        .where(
          (character) =>
              character.status.toLowerCase() == widget.status.toLowerCase(),
        )
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _characters = [...widget.characters];
    _favorites = {...widget.favorites};
    _nextPage = widget.nextPage;
    _scrollController.addListener(_loadWhenNearEnd);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _filteredCharacters.length < 6) _loadMore();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_loadWhenNearEnd)
      ..dispose();
    super.dispose();
  }

  void _loadWhenNearEnd() {
    if (_loadError == null &&
        _scrollController.hasClients &&
        _scrollController.position.extentAfter < 300) {
      _loadMore();
    }
  }

  void _close() {
    Navigator.pop(
      context,
      AllCharactersResult(characters: _characters, nextPage: _nextPage),
    );
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _nextPage == null) return;
    setState(() {
      _isLoadingMore = true;
      _loadError = null;
    });

    try {
      final result = await _api.fetchCharacters(page: _nextPage!);
      if (!mounted) return;
      setState(() {
        _characters.addAll(result.characters);
        _nextPage = result.nextPage;
        _isLoadingMore = false;
      });
      if (_filteredCharacters.length < 6 && _nextPage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _loadMore();
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _openCharacter(Character character) async {
    await widget.onCharacterTap(character);
    if (!mounted) return;
    setState(() {
      if (widget.isFavorite(character.id)) {
        _favorites.add(character.id);
      } else {
        _favorites.remove(character.id);
      }
    });
  }

  void _toggleFavorite(Character character) {
    setState(() {
      if (_favorites.contains(character.id)) {
        _favorites.remove(character.id);
      } else {
        _favorites.add(character.id);
      }
    });
    widget.onFavoriteToggle(character);
  }

  @override
  Widget build(BuildContext context) {
    final characters = _filteredCharacters;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: _close,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          widget.status == 'All'
              ? 'All Characters'
              : '${widget.status} Characters',
          style: TextStyle(color: AppColors.olive, fontWeight: FontWeight.w700),
        ),
      ),
      body: characters.isEmpty && _nextPage == null && _loadError == null
          ? const Center(
              child: EmptyCard(
                message: 'No characters found with this status.',
              ),
            )
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              itemCount: characters.length + (_nextPage != null ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == characters.length) {
                  if (_loadError != null) {
                    return Center(
                      child: TextButton(
                        onPressed: _loadMore,
                        child: const Text('Retry'),
                      ),
                    );
                  }
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.olive),
                    ),
                  );
                }

                final character = characters[index];
                return CharacterListCard(
                  character: character,
                  isFavorite: _favorites.contains(character.id),
                  onTap: () => _openCharacter(character),
                  onFavoriteTap: () => _toggleFavorite(character),
                );
              },
            ),
    );
  }
}
