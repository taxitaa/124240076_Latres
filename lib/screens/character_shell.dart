import 'package:flutter/material.dart';

import '../models/character.dart';
import '../services/character_api.dart';
import '../services/favorite_storage.dart';
import '../theme/app_colors.dart';
import 'character_detail_screen.dart';
import 'episodes_screen.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'saved_screen.dart';

class CharacterShell extends StatefulWidget {
  const CharacterShell({
    required this.username,
    required this.onLogout,
    super.key,
  });

  final String username;
  final Future<void> Function() onLogout;

  @override
  State<CharacterShell> createState() => _CharacterShellState();
}

class _CharacterShellState extends State<CharacterShell> {
  final _api = CharacterApi();
  final _exploreSearchController = TextEditingController();
  final _favorites = <int, Character>{};
  List<Character> _characters = [];
  int? _nextPage = 1;
  int _tabIndex = 0;
  String _query = '';
  String _filter = 'All';
  Object? _loadError;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _restoreFavorites();
    _loadCharacters();
  }

  @override
  void dispose() {
    _exploreSearchController.dispose();
    super.dispose();
  }

  List<Character> get _filteredCharacters {
    return _characters
        .where((character) {
          switch (_filter) {
            case 'Alive':
              return character.status.toLowerCase() == 'alive';
            case 'Dead':
              return character.status.toLowerCase() == 'dead';
            case 'Unknown':
              return character.status.toLowerCase() == 'unknown';
            default:
              return true;
          }
        })
        .toList(growable: false);
  }

  Future<void> _restoreFavorites() async {
    try {
      final saved = await FavoriteStorage.load();
      if (!mounted) return;
      setState(() {
        _favorites
          ..clear()
          ..addEntries(saved.map((character) => MapEntry(character.id, character)));
        _isReady = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isReady = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Favorit tidak dapat dimuat: $error')),
      );
    }
  }

  Future<void> _loadCharacters({bool append = false}) async {
    if (append) {
      if (_isLoadingMore || _nextPage == null) return;
      setState(() {
        _isLoadingMore = true;
        _loadError = null;
      });
    } else {
      setState(() {
        _isLoading = true;
        _loadError = null;
        _characters = [];
        _nextPage = 1;
      });
    }

    try {
      final result = await _api.fetchCharacters(
        page: append ? _nextPage! : 1,
        query: _query,
      );
      if (!mounted) return;
      setState(() {
        _characters = append
            ? [..._characters, ...result.characters]
            : result.characters;
        _nextPage = result.nextPage;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _search(String value) {
    final query = value.trim();
    if (query == _query) return;
    setState(() {
      _query = query;
      _filter = 'All';
    });
    _exploreSearchController.text = query;
    _loadCharacters();
  }

  Future<void> _toggleFavorite(Character character) async {
    setState(() {
      if (_favorites.containsKey(character.id)) {
        _favorites.remove(character.id);
      } else {
        _favorites[character.id] = character;
      }
    });
    try {
      await FavoriteStorage.save(_favorites.values);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Favorit tidak dapat disimpan: $error')),
        );
      }
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: Text('Keluar dari akun ${widget.username}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (shouldLogout == true) await widget.onLogout();
  }

  Future<void> _openDetails(Character character) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => CharacterDetailScreen(
          character: character,
          isFavorite: _favorites.containsKey(character.id),
          onFavoritePressed: () => _toggleFavorite(character),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pages = [
      HomeScreen(
        username: widget.username,
        characters: _characters,
        isLoading: _isLoading,
        loadError: _loadError,
        favorites: _favorites.keys.toSet(),
        onLogout: _confirmLogout,
        onFavoriteToggle: _toggleFavorite,
        onCharacterTap: _openDetails,
        onViewAll: () => setState(() => _tabIndex = 1),
        onRetry: _loadCharacters,
      ),
      ExploreScreen(
        characters: _filteredCharacters,
        isLoading: _isLoading,
        loadError: _loadError,
        searchController: _exploreSearchController,
        filter: _filter,
        favorites: _favorites.keys.toSet(),
        onLogout: _confirmLogout,
        nextPage: _nextPage,
        isLoadingMore: _isLoadingMore,
        onSearch: _search,
        onFilterSelected: (filter) => setState(() => _filter = filter),
        onFavoriteToggle: _toggleFavorite,
        onCharacterTap: _openDetails,
        onLoadMore: () => _loadCharacters(append: true),
        onRetry: _loadCharacters,
      ),
      EpisodesScreen(
        onLogout: _confirmLogout,
      ),
      SavedScreen(
        characters: _favorites.values.toList(growable: false),
        favorites: _favorites.keys.toSet(),
        onLogout: _confirmLogout,
        onCharacterTap: _openDetails,
        onFavoriteToggle: _toggleFavorite,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _tabIndex, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.olive,
        height: 72,
        destinations: [
          _navDestination(Icons.home_outlined, Icons.home_rounded, 'Home'),
          _navDestination(
            Icons.search_rounded,
            Icons.travel_explore_rounded,
            'Explore',
          ),
          _navDestination(
            Icons.movie_outlined,
            Icons.movie_rounded,
            'Episodes',
          ),
          _navDestination(
            Icons.favorite_border_rounded,
            Icons.favorite_rounded,
            'Saved',
          ),
        ],
      ),
    );
  }

  NavigationDestination _navDestination(
    IconData icon,
    IconData selectedIcon,
    String label,
  ) {
    return NavigationDestination(
      icon: Icon(icon, size: 21),
      selectedIcon: Icon(selectedIcon, size: 21, color: Colors.white),
      label: label,
    );
  }
}
