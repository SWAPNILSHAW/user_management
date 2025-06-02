import 'package:dio/dio.dart';
import '../constants.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../models/todo.dart';

class UserApiService {
  final Dio _dio = Dio();

  /// Fetches a list of users with pagination and optional search.
  /// [limit]: The number of users to fetch.
  /// [skip]: The number of users to skip.
  /// [query]: Optional search query for user names.
  Future<List<User>> fetchUsers({int limit = 10, int skip = 0, String? query}) async {
    try {
      String url = '${AppConstants.baseUrl}/users';
      final Map<String, dynamic> queryParams = {
        'limit': limit,
        'skip': skip,
      };

      if (query != null && query.isNotEmpty) {
        url = '${AppConstants.baseUrl}/users/search';
        queryParams['q'] = query; // Add search query
      }

      final response = await _dio.get(url, queryParameters: queryParams);

      if (response.statusCode == 200) {
        final List<dynamic> userJson = response.data['users'];
        return userJson.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Dio error: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Fetches posts for a specific user.
  /// [userId]: The ID of the user whose posts are to be fetched.
  Future<List<Post>> fetchUserPosts(int userId) async {
    try {
      final response = await _dio.get('${AppConstants.baseUrl}/posts/user/$userId');
      if (response.statusCode == 200) {
        final List<dynamic> postJson = response.data['posts'];
        return postJson.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user posts: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Dio error: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Fetches todos for a specific user.
  /// [userId]: The ID of the user whose todos are to be fetched.
  Future<List<Todo>> fetchUserTodos(int userId) async {
    try {
      final response = await _dio.get('${AppConstants.baseUrl}/todos/user/$userId');
      if (response.statusCode == 200) {
        final List<dynamic> todoJson = response.data['todos'];
        return todoJson.map((json) => Todo.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user todos: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Dio error: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}