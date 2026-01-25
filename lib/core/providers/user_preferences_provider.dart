import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesState {
  final bool isDarkMode;
  final bool isAutoTheme;
  final String languageLevel;
  final String userName;
  final String email;

  UserPreferencesState({
    this.isDarkMode = true,
    this.isAutoTheme = true,
    this.languageLevel = 'Intermediate',
    this.userName = 'Student',
    this.email = '',
  });

  UserPreferencesState copyWith({
    bool? isDarkMode,
    bool? isAutoTheme,
    String? languageLevel,
    String? userName,
    String? email,
  }) {
    return UserPreferencesState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isAutoTheme: isAutoTheme ?? this.isAutoTheme,
      languageLevel: languageLevel ?? this.languageLevel,
      userName: userName ?? this.userName,
      email: email ?? this.email,
    );
  }
}

class UserPreferencesNotifier extends StateNotifier<UserPreferencesState> {
  final SharedPreferences prefs;

  UserPreferencesNotifier(this.prefs) : super(UserPreferencesState()) {
    _loadState();
  }

  void _loadState() {
    state = UserPreferencesState(
      isDarkMode: prefs.getBool('isDarkMode') ?? true,
      isAutoTheme: prefs.getBool('isAutoTheme') ?? true,
      languageLevel: prefs.getString('languageLevel') ?? 'Intermediate',
      userName: prefs.getString('userName') ?? 'Student',
      email: prefs.getString('email') ?? '',
    );
  }

  Future<void> updateThemeMode({required bool isDark, required bool isAuto}) async {
    await prefs.setBool('isDarkMode', isDark);
    await prefs.setBool('isAutoTheme', isAuto);
    state = state.copyWith(isDarkMode: isDark, isAutoTheme: isAuto);
  }

  Future<void> updateProfile({String? name, String? email, String? level}) async {
    if (name != null) {
      await prefs.setString('userName', name);
    }
    if (email != null) {
      await prefs.setString('email', email);
    }
    if (level != null) {
      await prefs.setString('languageLevel', level);
    }
    state = state.copyWith(userName: name, email: email, languageLevel: level);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Provider was not initialized');
});

final userPreferencesProvider = StateNotifierProvider<UserPreferencesNotifier, UserPreferencesState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UserPreferencesNotifier(prefs);
});
