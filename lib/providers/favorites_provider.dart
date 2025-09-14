import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/pair.dart';

class FavoritesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    _loadFavorites();
    return [];
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = prefs.getStringList('favorite_tokens') ?? [];
      state = favoriteIds;
    } catch (e) {
      state = [];
    }
  }

  Future<void> toggleFavorite(String pairId) async {
    final currentFavorites = List<String>.from(state);
    
    if (currentFavorites.contains(pairId)) {
      currentFavorites.remove(pairId);
    } else {
      currentFavorites.add(pairId);
    }
    
    state = currentFavorites;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorite_tokens', currentFavorites);
    } catch (e) {
      // Handle error silently
    }
  }

  bool isFavorite(String pairId) {
    return state.contains(pairId);
  }

  Future<void> clearFavorites() async {
    state = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('favorite_tokens');
    } catch (e) {
      // Handle error silently
    }
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, List<String>>(() {
  return FavoritesNotifier();
});
