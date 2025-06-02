import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/post.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final List<Post> _localPosts = [];

  PostBloc() : super(PostInitial()) {
    on<AddPost>(_onAddPost);
    on<LoadPosts>(_onLoadPosts);
  }

  void _onAddPost(AddPost event, Emitter<PostState> emit) async {
    _localPosts.add(event.post);
    await _savePostsToPrefs();
    emit(PostLoaded(List.from(_localPosts)));
  }

  void _onLoadPosts(LoadPosts event, Emitter<PostState> emit) async {
    await _loadPostsFromPrefs();
    emit(PostLoaded(List.from(_localPosts)));
  }

  Future<void> _savePostsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final postListJson = jsonEncode(_localPosts.map((e) => e.toJson()).toList());
    await prefs.setString('posts', postListJson);
  }

  Future<void> _loadPostsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final postListJson = prefs.getString('posts');
    if (postListJson != null) {
      final List<dynamic> decodedList = jsonDecode(postListJson);
      _localPosts
        ..clear()
        ..addAll(decodedList.map((e) => Post.fromJson(e)).toList());
    }
  }
}
