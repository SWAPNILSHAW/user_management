import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/user_api_service.dart';
import 'blocs/post_bloc/post_bloc.dart';
import 'blocs/user_bloc/user_bloc.dart';
import 'repositories/user_repository.dart';
import 'screens/create_post_screen.dart';
import 'screens/user_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatefulWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme

  void _toggleTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserApiService>(
          create: (context) => UserApiService(),
        ),
        RepositoryProvider<UserRepository>(
          create: (context) => UserRepository(
            userApiService: RepositoryProvider.of<UserApiService>(context),
            prefs: widget.prefs,
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<UserBloc>(
            create: (context) => UserBloc(
              userRepository: RepositoryProvider.of<UserRepository>(context),
            ),
          ),
          BlocProvider<PostBloc>(
            create: (context) => PostBloc(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter User Management',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.light,
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.blueGrey,
            brightness: Brightness.dark,
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blueGrey,
              foregroundColor: Colors.white,
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.blueGrey,
              foregroundColor: Colors.white,
            ),
          ),
          themeMode: _themeMode,
          home: UserListWrapper(toggleTheme: _toggleTheme),
        ),
      ),
    );
  }
}

// A wrapper to hold the UserListScreen and the FloatingActionButton
class UserListWrapper extends StatelessWidget {
  final Function(ThemeMode) toggleTheme;

  const UserListWrapper({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const UserListScreen(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'addPost',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreatePostScreen()),
              );
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'toggleTheme',
            onPressed: () {
              final currentBrightness = Theme.of(context).brightness;
              if (currentBrightness == Brightness.light) {
                toggleTheme(ThemeMode.dark);
              } else {
                toggleTheme(ThemeMode.light);
              }
            },
            child: const Icon(Icons.brightness_6), // Icon for theme toggle
          ),
        ],
      ),
    );
  }
}