import 'package:flutter/material.dart';

import '../services/character_api.dart';
import '../theme/app_colors.dart';
import '../widgets/character_widgets.dart';

class EpisodesScreen extends StatefulWidget {
  const EpisodesScreen({
    required this.onLogout,
    super.key,
  });

  final VoidCallback onLogout;

  @override
  State<EpisodesScreen> createState() => _EpisodesScreenState();
}

class _EpisodesScreenState extends State<EpisodesScreen> {
  final _api = CharacterApi();
  final _episodes = <Episode>[];
  int? _nextPage = 1;
  Object? _error;
  bool _isLoading = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadEpisodes();
  }

  Future<void> _loadEpisodes({bool append = false}) async {
    if (append) {
      if (_isLoadingMore || _nextPage == null) return;
      setState(() {
        _isLoadingMore = true;
        _error = null;
      });
    } else {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final result = await _api.fetchEpisodes(page: append ? _nextPage! : 1);
      if (!mounted) return;
      setState(() {
        if (append) {
          _episodes.addAll(result.episodes);
        } else {
          _episodes
            ..clear()
            ..addAll(result.episodes);
        }
        _nextPage = result.nextPage;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      children: [
        BrandHeader(onLogout: widget.onLogout),
        const SizedBox(height: 28),
        const Text(
          'Episodes',
          style: TextStyle(
            color: AppColors.olive,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 5),
        Text('Episode dari semesta Rick and Morty.', style: mutedTextStyle),
        const SizedBox(height: 20),
        if (_isLoading)
          const LoadingCard(height: 180)
        else if (_error != null)
          ErrorCard(error: _error!, onRetry: _loadEpisodes)
        else if (_episodes.isEmpty)
          const EmptyCard(message: 'Episode tidak ditemukan.')
        else
          ..._episodes.map(
            (episode) => Container(
              margin: const EdgeInsets.only(bottom: 11),
              padding: const EdgeInsets.all(16),
              decoration: cardDecoration(),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.olive.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.movie_outlined,
                      color: AppColors.olive,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          episode.name,
                          style: const TextStyle(
                            color: AppColors.olive,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(episode.airDate, style: mutedTextStyle),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (!_isLoading && _error == null && _nextPage != null)
          OutlinedButton(
            onPressed: _isLoadingMore
                ? null
                : () => _loadEpisodes(append: true),
            child: _isLoadingMore
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Muat episode lainnya'),
          ),
      ],
    );
  }
}
