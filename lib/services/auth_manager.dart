// services/auth_manager.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../utils/logger.dart';
import 'auth_service.dart';

class AuthManager extends ChangeNotifier {
  static final AuthManager _instance = AuthManager._internal();
  factory AuthManager() => _instance;
  AuthManager._internal();

  // Constants for SharedPreferences keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _expiryKey = 'token_expiry';
  static const String _isLoggedInKey = 'is_logged_in';

  // Private variables
  String? _token;
  User? _user;
  String? _tokenExpiry;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _isInitialized = false;

  // Getters
  String? get token => _token;
  User? get user => _user;
  String? get tokenExpiry => _tokenExpiry;
  bool get isLoggedIn => _isLoggedIn && _token != null && !_isTokenExpired();
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  // ================ INITIALIZATION ================

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      Logger.logInfo('Initializing AuthManager');
      await _loadAuthDataFromStorage();

      // Check if token is expired
      if (_isLoggedIn && _token != null) {
        if (_isTokenExpired()) {
          Logger.logWarning('Token expired during initialization');
          await logout();
        } else {
          // Verify token with server
          await _verifyTokenWithServer();
        }
      }

      _isInitialized = true;
      Logger.logSuccess('AuthManager initialized successfully');
    } catch (e) {
      Logger.logError('Failed to initialize AuthManager', e);
      await _clearAuthData();
      _isInitialized = true; // Still mark as initialized even if failed
    }

    notifyListeners();
  }

  // ================ ORDER API COMPATIBILITY METHODS ================

  /// Get the authentication token for API requests
  /// This method is specifically for OrderApiService compatibility
  Future<String?> getToken() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!hasValidToken()) {
      return null;
    }

    return _token;
  }

  /// Check if user has a valid, non-expired token
  /// Enhanced version for OrderApiService compatibility
  bool hasValidToken() {
    if (!_isInitialized) {
      return false;
    }

    return _token != null &&
        _token!.isNotEmpty &&
        _isLoggedIn &&
        !_isTokenExpired();
  }

  /// Get authentication headers for API requests
  /// Enhanced version with better error handling
  Future<Map<String, String>> getAuthHeaders() async {
    final baseHeaders = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (hasValidToken() && _token != null) {
      baseHeaders['Authorization'] = 'Bearer $_token';
    }

    return baseHeaders;
  }

  // ================ LOGIN ================

  Future<bool> login({
    required String emailUsername,
    required String password,
  }) async {
    try {
      _setLoading(true);
      Logger.logInfo('Starting login process');

      final loginResponse = await AuthService.login(
        emailUsername: emailUsername,
        password: password,
      );

      if (loginResponse.success) {
        await _setAuthData(
          token: loginResponse.token,
          user: loginResponse.user,
          expiry: loginResponse.expiredAt,
        );

        Logger.logSuccess('Login successful for ${loginResponse.user.username}');
        return true;
      } else {
        Logger.logError('Login failed: ${loginResponse.message}', null);
        return false;
      }

    } catch (e) {
      Logger.logError('Login error in AuthManager', e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ================ LOGOUT ================

  Future<void> logout() async {
    try {
      _setLoading(true);
      Logger.logInfo('Starting logout process');

      // Call logout API if token exists
      if (_token != null) {
        try {
          await AuthService.logout(_token!);
        } catch (e) {
          Logger.logWarning('Logout API call failed, but continuing with local cleanup', e);
        }
      }

      // Clear local auth data
      await _clearAuthData();

      Logger.logSuccess('Logout completed successfully');
    } catch (e) {
      Logger.logError('Logout error', e);
      // Still clear local data even if API call fails
      await _clearAuthData();
    } finally {
      _setLoading(false);
    }
  }

  // ================ REFRESH USER DATA ================

  Future<bool> refreshUserData() async {
    if (!hasValidToken() || _token == null) {
      Logger.logWarning('Cannot refresh user data - not logged in or invalid token');
      return false;
    }

    try {
      _setLoading(true);
      Logger.logInfo('Refreshing user data');

      final updatedUser = await AuthService.getUserDetails(_token!);

      _user = updatedUser;
      await _saveUserToStorage();

      Logger.logSuccess('User data refreshed successfully');
      return true;

    } catch (e) {
      Logger.logError('Failed to refresh user data', e);

      // If token is invalid, logout
      if (AuthService.isAuthError(e)) {
        Logger.logWarning('Token invalid during user data refresh, logging out');
        await logout();
      }

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ================ UPDATE PROFILE ================

  Future<bool> updateProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    if (!hasValidToken() || _token == null) {
      Logger.logWarning('Cannot update profile - not logged in or invalid token');
      return false;
    }

    try {
      _setLoading(true);
      Logger.logInfo('Updating user profile');

      final updatedUser = await AuthService.updateProfile(
        token: _token!,
        name: name,
        email: email,
        phone: phone,
      );

      _user = updatedUser;
      await _saveUserToStorage();

      Logger.logSuccess('Profile updated successfully');
      return true;

    } catch (e) {
      Logger.logError('Failed to update profile', e);

      // If token is invalid, logout
      if (AuthService.isAuthError(e)) {
        Logger.logWarning('Token invalid during profile update, logging out');
        await logout();
      }

      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ================ UPLOAD AVATAR ================

  Future<String?> uploadAvatar(String imagePath) async {
    if (!hasValidToken() || _token == null) {
      Logger.logWarning('Cannot upload avatar - not logged in or invalid token');
      return null;
    }

    try {
      _setLoading(true);
      Logger.logInfo('Uploading user avatar');

      final avatarUrl = await AuthService.uploadAvatar(
        token: _token!,
        imagePath: imagePath,
      );

      // Update user with new profile image
      if (_user != null) {
        _user = _user!.copyWith(profileImage: avatarUrl);
        await _saveUserToStorage();
      }

      Logger.logSuccess('Avatar uploaded successfully');
      return avatarUrl;

    } catch (e) {
      Logger.logError('Failed to upload avatar', e);

      // If token is invalid, logout
      if (AuthService.isAuthError(e)) {
        Logger.logWarning('Token invalid during avatar upload, logging out');
        await logout();
      }

      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ================ TOKEN VALIDATION ================

  Future<bool> validateToken() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isLoggedIn || _token == null) {
      Logger.logInfo('Token validation failed - not logged in or no token');
      return false;
    }

    if (_isTokenExpired()) {
      Logger.logWarning('Token expired during validation');
      await logout();
      return false;
    }

    // Verify with server
    try {
      await _verifyTokenWithServer();
      Logger.logInfo('Token validation successful');
      return true;
    } catch (e) {
      Logger.logWarning('Token validation failed with server');
      if (AuthService.isAuthError(e)) {
        await logout();
      }
      return false;
    }
  }

  bool _isTokenExpired() {
    if (_tokenExpiry == null) {
      Logger.logInfo('No token expiry set, assuming token is valid');
      return false;
    }

    try {
      final expiryDate = DateTime.parse(_tokenExpiry!);
      final now = DateTime.now();
      final isExpired = now.isAfter(expiryDate);

      if (isExpired) {
        Logger.logWarning('Token expired: $expiryDate vs current: $now');
      }

      return isExpired;
    } catch (e) {
      Logger.logError('Error parsing token expiry date: $_tokenExpiry', e);
      return false;
    }
  }

  Future<void> _verifyTokenWithServer() async {
    try {
      if (_token == null) {
        throw Exception('No token available for verification');
      }

      await AuthService.getUserDetails(_token!);
      Logger.logInfo('Token verified with server successfully');
    } catch (e) {
      Logger.logWarning('Token verification failed with server: $e');
      if (AuthService.isAuthError(e)) {
        throw e; // Re-throw auth errors to trigger logout
      }
    }
  }

  // ================ PRIVATE METHODS ================

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  Future<void> _setAuthData({
    required String token,
    required User user,
    required String expiry,
  }) async {
    _token = token;
    _user = user;
    _tokenExpiry = expiry;
    _isLoggedIn = true;

    await _saveAuthDataToStorage();
    Logger.logInfo('Auth data set successfully for user: ${user.username}');
    notifyListeners();
  }

  Future<void> _clearAuthData() async {
    final wasLoggedIn = _isLoggedIn;

    _token = null;
    _user = null;
    _tokenExpiry = null;
    _isLoggedIn = false;

    await _clearAuthDataFromStorage();

    if (wasLoggedIn) {
      Logger.logInfo('Auth data cleared - user logged out');
    }

    notifyListeners();
  }

  // ================ STORAGE METHODS ================

  Future<void> _saveAuthDataToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_token != null) {
        await prefs.setString(_tokenKey, _token!);
      }

      if (_user != null) {
        await prefs.setString(_userKey, json.encode(_user!.toJson()));
      }

      if (_tokenExpiry != null) {
        await prefs.setString(_expiryKey, _tokenExpiry!);
      }

      await prefs.setBool(_isLoggedInKey, _isLoggedIn);

      Logger.logInfo('Auth data saved to storage successfully');
    } catch (e) {
      Logger.logError('Failed to save auth data to storage', e);
    }
  }

  Future<void> _saveUserToStorage() async {
    try {
      if (_user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, json.encode(_user!.toJson()));
        Logger.logInfo('User data saved to storage');
        notifyListeners();
      }
    } catch (e) {
      Logger.logError('Failed to save user data to storage', e);
    }
  }

  Future<void> _loadAuthDataFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _token = prefs.getString(_tokenKey);
      _tokenExpiry = prefs.getString(_expiryKey);
      _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        try {
          final userData = json.decode(userJson);
          _user = User.fromJson(userData);
        } catch (e) {
          Logger.logError('Failed to parse user data from storage', e);
          _user = null;
        }
      }

      Logger.logInfo('Auth data loaded from storage - IsLoggedIn: $_isLoggedIn, HasToken: ${_token != null}');
    } catch (e) {
      Logger.logError('Failed to load auth data from storage', e);
    }
  }

  Future<void> _clearAuthDataFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      await prefs.remove(_expiryKey);
      await prefs.remove(_isLoggedInKey);

      Logger.logInfo('Auth data cleared from storage');
    } catch (e) {
      Logger.logError('Failed to clear auth data from storage', e);
    }
  }

  // ================ UTILITY METHODS (LEGACY SUPPORT) ================

  /// Legacy method - use getToken() instead for new code
  String? getAuthToken() {
    return _token;
  }

  /// Legacy method - use getAuthHeaders() instead for new code
  Map<String, String> getAuthHeadersSync() {
    if (_token != null && hasValidToken()) {
      return {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
    }
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  // ================ DEBUG METHODS ================

  void debugPrintAuthState() {
    if (kDebugMode) {
      Logger.logInfo('=== AuthManager Debug State ===');
      Logger.logInfo('Initialized: $_isInitialized');
      Logger.logInfo('Is Logged In: $_isLoggedIn');
      Logger.logInfo('Has Token: ${_token != null}');
      Logger.logInfo('Token Expired: ${_isTokenExpired()}');
      Logger.logInfo('Has Valid Token: ${hasValidToken()}');
      Logger.logInfo('User: ${_user?.username ?? 'null'}');
      Logger.logInfo('Token Expiry: $_tokenExpiry');
      Logger.logInfo('===============================');
    }
  }

  // ================ CLEANUP ================

  @override
  void dispose() {
    Logger.logInfo('AuthManager disposed');
    super.dispose();
  }
}