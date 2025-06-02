import 'package:shared_preferences/shared_preferences.dart';
import '../api/user_api_service.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../models/todo.dart';
import 'dart:convert'; // For JSON encoding/decoding

class UserRepository {
  final UserApiService userApiService;
  final SharedPreferences _prefs; // For caching

  UserRepository({required this.userApiService, required SharedPreferences prefs}) : _prefs = prefs;

  static const String _cachedUsersKey = 'cached_users';

  /// Fetches users, attempting to load from cache first.
  /// If [forceRefresh] is true, it bypasses the cache.
  Future<List<User>> getUsers({int limit = 10, int skip = 0, String? query, bool forceRefresh = false}) async {
    // Only attempt to load from cache for the initial fetch of the full list (no search, first page)
    if (!forceRefresh && query == null && skip == 0) {
      final cachedData = _prefs.getString(_cachedUsersKey);
      if (cachedData != null) {
        try {
          final List<dynamic> jsonList = json.decode(cachedData);
          return jsonList.map((json) => User.fromJson(json)).toList();
        } catch (e) {
          // If parsing fails, log the error and proceed to fetch from API
          print('Error parsing cached users: $e');
        }
      }
    }

    // Fetch from API
    final users = await userApiService.fetchUsers(limit: limit, skip: skip, query: query);

    // Cache the initial fetch if no query and no skip (i.e., first page)
    if (query == null && skip == 0) {
      _prefs.setString(_cachedUsersKey, json.encode(users.map((user) => user.toJson()).toList()));
    }
    return users;
  }

  Future<List<Post>> getUserPosts(int userId) async {
    return await userApiService.fetchUserPosts(userId);
  }

  Future<List<Todo>> getUserTodos(int userId) async {
    return await userApiService.fetchUserTodos(userId);
  }
}