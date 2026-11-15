import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/character.dart';

class FavoriteStorage {
  static const _key = 'favorite_characters';

  static Future<List<Character>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getStringList(_key) ?? const <String>[];
    return saved
        .map(
          (item) =>
              Character.fromJson(jsonDecode(item) as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  static Future<void> save(Iterable<Character> characters) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _key,
      characters.map((character) => jsonEncode(character.toJson())).toList(),
    );
  }
}
