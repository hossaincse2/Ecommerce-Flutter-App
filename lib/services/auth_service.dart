// services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';
import 'api_client.dart';

class AuthService {
  static const String _baseUrl = 'https://admin.karbar.shop/api';
  static const Duration _timeout = Duration(seconds: 30);

  // ================ LOGIN API ================

  static Future<LoginResponse> login({
    required String emailUsername,
    required String password,
  }) async {
    try {
      if (emailUsername.trim().isEmpty) {
        throw AuthException('Email/Username cannot be empty');
      }

      if (password.trim().isEmpty) {
        throw AuthException('Password cannot be empty');
      }

      Logger.logInfo('Attempting login for user: $emailUsername');

      final url = Uri.parse('$_baseUrl/login');
      final body = {
        'email_username': emailUsername.trim(),
        'password': password,
      };

      Logger.logInfo('Login URL: $url');
      Logger.logInfo('Login payload: ${json.encode(body)}');

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'User-Agent': 'Karbar-Shop-App/1.0.0',
        },
        body: json.encode(body),
      ).timeout(_timeout);

      Logger.logInfo('Login response status: ${response.statusCode}');
      Logger.logInfo('Login response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          final loginResponse = LoginResponse.fromJson(data);
          Logger.logSuccess('Login successful for user: ${loginResponse.user.username}');
          return loginResponse;
        } else {
          final errorMessage = data['message'] ?? 'Login failed';
          Logger.logError('Login failed: $errorMessage', null);
          throw AuthException(errorMessage);
        }
      } else if (response.statusCode == 401) {
        final errorMessage = data['message'] ?? 'Invalid credentials';
        Logger.logError('Login failed - Invalid credentials: $errorMessage', null);
        throw AuthException(errorMessage);
      } else if (response.statusCode == 422) {
        final errorMessage = data['message'] ?? 'Validation error';
        Logger.logError('Login failed - Validation error: $errorMessage', null);
        throw AuthException(errorMessage);
      } else {
        final errorMessage = data['message'] ?? 'Login failed with status ${response.statusCode}';
        Logger.logError('Login failed: $errorMessage', null);
        throw AuthException(errorMessage);
      }

    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }

      Logger.logError('Login error', e);

      if (e.toString().contains('TimeoutException')) {
        throw AuthException('Connection timeout. Please check your internet connection.');
      } else if (e.toString().contains('SocketException')) {
        throw AuthException('Network error. Please check your internet connection.');
      } else {
        throw AuthException('Login failed: ${e.toString()}');
      }
    }
  }

  // ================ GET USER DETAILS API ================

  static Future<User> getUserDetails(String token) async {
    try {
      if (token.trim().isEmpty) {
        throw AuthException('Authentication token is required');
      }

      Logger.logInfo('Fetching user details');

      final url = Uri.parse('$_baseUrl/user/details');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'User-Agent': 'Karbar-Shop-App/1.0.0',
        },
      ).timeout(_timeout);

      Logger.logInfo('User details response status: ${response.statusCode}');
      Logger.logInfo('User details response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Handle different response structures
        User user;
        if (data['user'] != null) {
          user = User.fromJson(data['user']);
        } else if (data['data'] != null) {
          user = User.fromJson(data['data']);
        } else if (data['success'] == true && data.containsKey('name')) {
          // Direct user data in response
          user = User.fromJson(data);
        } else {
          throw AuthException('Invalid response format from server');
        }

        Logger.logSuccess('Successfully fetched user details for: ${user.username}');
        return user;
      } else if (response.statusCode == 401) {
        Logger.logError('Unauthorized - Invalid or expired token', null);
        throw AuthException('Session expired. Please login again.');
      } else {
        final errorMessage = data['message'] ?? 'Failed to fetch user details';
        Logger.logError('Failed to fetch user details: $errorMessage', null);
        throw AuthException(errorMessage);
      }

    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }

      Logger.logError('Get user details error', e);

      if (e.toString().contains('TimeoutException')) {
        throw AuthException('Connection timeout. Please check your internet connection.');
      } else if (e.toString().contains('SocketException')) {
        throw AuthException('Network error. Please check your internet connection.');
      } else {
        throw AuthException('Failed to fetch user details: ${e.toString()}');
      }
    }
  }

  // ================ UPDATE PROFILE API ================

  static Future<User> updateProfile({
    required String token,
    required String name,
    required String email,
    String? phone,
  }) async {
    try {
      if (token.trim().isEmpty) {
        throw AuthException('Authentication token is required');
      }

      if (name.trim().isEmpty) {
        throw AuthException('Name cannot be empty');
      }

      if (email.trim().isEmpty) {
        throw AuthException('Email cannot be empty');
      }

      Logger.logInfo('Updating user profile');

      final url = Uri.parse('$_baseUrl/user/profile-update');
      final body = {
        'name': name.trim(),
        'email': email.trim(),
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      };

      Logger.logInfo('Profile update URL: $url');
      Logger.logInfo('Profile update payload: ${json.encode(body)}');

      final response = await http.put(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'User-Agent': 'Karbar-Shop-App/1.0.0',
        },
        body: json.encode(body),
      ).timeout(_timeout);

      Logger.logInfo('Profile update response status: ${response.statusCode}');
      Logger.logInfo('Profile update response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Check for success in different ways
        final isSuccess = data['success'] == true ||
            (data['message'] != null && data['message'].toString().toLowerCase().contains('successfully'));

        if (isSuccess) {
          // Handle different response structures
          User user;
          if (data['user'] != null) {
            user = User.fromJson(data['user']);
          } else if (data['data'] != null) {
            user = User.fromJson(data['data']);
          } else {
            // If no user data returned, fetch fresh user details
            Logger.logInfo('No user data in response, fetching fresh user details');
            user = await getUserDetails(token);
          }

          Logger.logSuccess('Successfully updated profile for: ${user.username}');
          return user;
        } else {
          final errorMessage = data['message'] ?? 'Failed to update profile';
          Logger.logError('Profile update failed: $errorMessage', null);
          throw AuthException(errorMessage);
        }
      } else if (response.statusCode == 401) {
        Logger.logError('Unauthorized - Invalid or expired token', null);
        throw AuthException('Session expired. Please login again.');
      } else if (response.statusCode == 422) {
        final errorMessage = data['message'] ?? 'Validation error';
        final errors = data['errors'];
        if (errors != null && errors is Map) {
          final firstError = errors.values.first;
          final errorText = firstError is List ? firstError.first : firstError.toString();
          throw AuthException(errorText);
        }
        throw AuthException(errorMessage);
      } else {
        final errorMessage = data['message'] ?? 'Failed to update profile';
        Logger.logError('Profile update failed: $errorMessage', null);
        throw AuthException(errorMessage);
      }

    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }

      Logger.logError('Profile update error', e);

      if (e.toString().contains('TimeoutException')) {
        throw AuthException('Connection timeout. Please check your internet connection.');
      } else if (e.toString().contains('SocketException')) {
        throw AuthException('Network error. Please check your internet connection.');
      } else {
        throw AuthException('Failed to update profile: ${e.toString()}');
      }
    }
  }

  // ================ UPLOAD AVATAR API ================

  static Future<String> uploadAvatar({
    required String token,
    required String imagePath,
  }) async {
    try {
      if (token.trim().isEmpty) {
        throw AuthException('Authentication token is required');
      }

      if (imagePath.trim().isEmpty) {
        throw AuthException('Image path is required');
      }

      Logger.logInfo('Uploading user avatar');

      final url = Uri.parse('$_baseUrl/user/avater-upload');

      // Create multipart request
      final request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'User-Agent': 'Karbar-Shop-App/1.0.0',
      });

      // Add file
      final file = await http.MultipartFile.fromPath('avatar', imagePath);
      request.files.add(file);

      Logger.logInfo('Avatar upload URL: $url');
      Logger.logInfo('Avatar file path: $imagePath');

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      Logger.logInfo('Avatar upload response status: ${response.statusCode}');
      Logger.logInfo('Avatar upload response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          final avatarUrl = data['avatar_url'] ?? data['image_url'] ?? data['url'] ?? '';
          Logger.logSuccess('Successfully uploaded avatar: $avatarUrl');
          return avatarUrl;
        } else {
          final errorMessage = data['message'] ?? 'Failed to upload avatar';
          Logger.logError('Avatar upload failed: $errorMessage', null);
          throw AuthException(errorMessage);
        }
      } else if (response.statusCode == 401) {
        Logger.logError('Unauthorized - Invalid or expired token', null);
        throw AuthException('Session expired. Please login again.');
      } else if (response.statusCode == 422) {
        final errorMessage = data['message'] ?? 'Validation error';
        final errors = data['errors'];
        if (errors != null && errors is Map) {
          final firstError = errors.values.first;
          final errorText = firstError is List ? firstError.first : firstError.toString();
          throw AuthException(errorText);
        }
        throw AuthException(errorMessage);
      } else {
        final errorMessage = data['message'] ?? 'Failed to upload avatar';
        Logger.logError('Avatar upload failed: $errorMessage', null);
        throw AuthException(errorMessage);
      }

    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }

      Logger.logError('Avatar upload error', e);

      if (e.toString().contains('TimeoutException')) {
        throw AuthException('Connection timeout. Please check your internet connection.');
      } else if (e.toString().contains('SocketException')) {
        throw AuthException('Network error. Please check your internet connection.');
      } else {
        throw AuthException('Failed to upload avatar: ${e.toString()}');
      }
    }
  }

  // ================ LOGOUT API ================

  static Future<bool> logout(String token) async {
    try {
      if (token.trim().isEmpty) {
        Logger.logWarning('No token provided for logout');
        return true; // Consider it successful if no token
      }

      Logger.logInfo('Attempting logout');

      final url = Uri.parse('$_baseUrl/logout');

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'User-Agent': 'Karbar-Shop-App/1.0.0',
        },
      ).timeout(_timeout);

      Logger.logInfo('Logout response status: ${response.statusCode}');
      Logger.logInfo('Logout response body: ${response.body}');

      if (response.statusCode == 200) {
        Logger.logSuccess('Logout successful');
        return true;
      } else {
        Logger.logWarning('Logout API failed but proceeding with local logout');
        return true; // Even if API fails, we should still logout locally
      }

    } catch (e) {
      Logger.logError('Logout error', e);
      // Don't throw error for logout - always proceed with local logout
      return true;
    }
  }

  // ================ HELPER METHODS ================

  static String getErrorMessage(dynamic error) {
    if (error is AuthException) {
      return error.message;
    }
    return 'An unexpected error occurred';
  }

  static bool isNetworkError(dynamic error) {
    if (error is AuthException) {
      return error.message.contains('Network') ||
          error.message.contains('connection') ||
          error.message.contains('timeout');
    }
    return false;
  }

  static bool isAuthError(dynamic error) {
    if (error is AuthException) {
      return error.message.contains('Session expired') ||
          error.message.contains('Unauthorized') ||
          error.message.contains('Invalid credentials');
    }
    return false;
  }
}

// ================ CUSTOM EXCEPTION CLASS ================

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  AuthException(this.message, {this.statusCode});

  @override
  String toString() => 'AuthException: $message';
}