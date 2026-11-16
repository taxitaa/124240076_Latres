import 'dart:convert';
import 'dart:io';

import '../models/character.dart';

class CharacterPage {
  const CharacterPage({required this.characters, required this.nextPage});

  final List<Character> characters;
  final int? nextPage;
}

class Episode {
  const Episode({
    required this.id,
    required this.name,
    required this.airDate,
  });

  final int id;
  final String name;
  final String airDate;

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
    id: json['id'] as int,
    name: json['name'] as String,
    airDate: json['air_date'] as String,
  );
}

class EpisodePage {
  const EpisodePage({required this.episodes, required this.nextPage});

  final List<Episode> episodes;
  final int? nextPage;
}

class CharacterApi {
  static const _url = 'https://rickandmortyapi.com/api/character';
  static const _episodeUrl = 'https://rickandmortyapi.com/api/episode';

  Future<CharacterPage> fetchCharacters({int page = 1}) async {
    final uri = Uri.parse(_url).replace(
      queryParameters: {'page': '$page'},
    );
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);

    try {
      final request = await client
          .getUrl(uri)
          .timeout(const Duration(seconds: 15));
      final response = await request.close().timeout(
        const Duration(seconds: 15),
      );
      final body = await utf8.decoder
          .bind(response)
          .join()
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'Server mengembalikan status ${response.statusCode}.',
          uri: uri,
        );
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Format data karakter tidak valid.');
      }
      final info = decoded['info'];
      final results = decoded['results'];
      if (info is! Map<String, dynamic> || results is! List<dynamic>) {
        throw const FormatException('Data karakter dari server tidak lengkap.');
      }

      final nextUrl = info['next'] as String?;
      final nextPage = nextUrl == null
          ? null
          : int.tryParse(Uri.parse(nextUrl).queryParameters['page'] ?? '');
      final characters = results
          .whereType<Map<String, dynamic>>()
          .map(Character.fromJson)
          .toList(growable: false);

      return CharacterPage(characters: characters, nextPage: nextPage);
    } finally {
      client.close(force: true);
    }
  }

  Future<EpisodePage> fetchEpisodes({int page = 1}) async {
    final uri = Uri.parse(_episodeUrl).replace(
      queryParameters: {'page': '$page'},
    );
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);

    try {
      final request = await client
          .getUrl(uri)
          .timeout(const Duration(seconds: 15));
      final response = await request.close().timeout(
        const Duration(seconds: 15),
      );
      final body = await utf8.decoder
          .bind(response)
          .join()
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'Server mengembalikan status ${response.statusCode}.',
          uri: uri,
        );
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Format data episode tidak valid.');
      }
      final info = decoded['info'];
      final results = decoded['results'];
      if (info is! Map<String, dynamic> || results is! List<dynamic>) {
        throw const FormatException('Data episode dari server tidak lengkap.');
      }
      final nextUrl = info['next'] as String?;
      final nextPage = nextUrl == null
          ? null
          : int.tryParse(Uri.parse(nextUrl).queryParameters['page'] ?? '');
      final episodes = results
          .whereType<Map<String, dynamic>>()
          .map(Episode.fromJson)
          .toList(growable: false);
      return EpisodePage(episodes: episodes, nextPage: nextPage);
    } finally {
      client.close(force: true);
    }
  }
}
