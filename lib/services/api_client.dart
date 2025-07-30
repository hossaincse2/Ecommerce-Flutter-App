import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../constants/api_constants.dart';
import '../utils/logger.dart';

// Custom Exception class for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class ApiClient {
  late http.Client _client;

  void initialize() {
    _client = http.Client();
    Logger.logInfo('ApiClient initialized');
  }

  void dispose() {
    _client.close();
    Logger.logInfo('ApiClient disposed');
  }

  Future<Map<String, dynamic>> get(
      String endpoint, {
        Map<String, String>? queryParameters,
      }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      Logger.logInfo('GET request to: $uri');

      final response = await _client.get(
        uri,
        headers: ApiConstants.defaultHeaders,
      ).timeout(Duration(seconds: AppConfig.requestTimeout));

      return _handleResponse(response);
    } on TimeoutException {
      Logger.logError('Request timeout for GET $endpoint');
      throw ApiException(ApiConstants.timeoutErrorMessage);
    } on SocketException {
      Logger.logError('Network error for GET $endpoint');
      throw ApiException(ApiConstants.networkErrorMessage);
    } catch (e) {
      Logger.logError('Unexpected error for GET $endpoint', e);
      throw ApiException('${ApiConstants.unknownErrorMessage}: $e');
    }
  }

  Future<Map<String, dynamic>> post(
      String endpoint, {
        Map<String, String>? queryParameters,
        Map<String, dynamic>? body,
      }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      Logger.logInfo('POST request to: $uri');

      final response = await _client.post(
        uri,
        headers: ApiConstants.defaultHeaders,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(Duration(seconds: AppConfig.requestTimeout));

      return _handleResponse(response);
    } on TimeoutException {
      Logger.logError('Request timeout for POST $endpoint');
      throw ApiException(ApiConstants.timeoutErrorMessage);
    } on SocketException {
      Logger.logError('Network error for POST $endpoint');
      throw ApiException(ApiConstants.networkErrorMessage);
    } catch (e) {
      Logger.logError('Unexpected error for POST $endpoint', e);
      throw ApiException('${ApiConstants.unknownErrorMessage}: $e');
    }
  }

  Future<Map<String, dynamic>> put(
      String endpoint, {
        Map<String, String>? queryParameters,
        Map<String, dynamic>? body,
      }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      Logger.logInfo('PUT request to: $uri');

      final response = await _client.put(
        uri,
        headers: ApiConstants.defaultHeaders,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(Duration(seconds: AppConfig.requestTimeout));

      return _handleResponse(response);
    } on TimeoutException {
      Logger.logError('Request timeout for PUT $endpoint');
      throw ApiException(ApiConstants.timeoutErrorMessage);
    } on SocketException {
      Logger.logError('Network error for PUT $endpoint');
      throw ApiException(ApiConstants.networkErrorMessage);
    } catch (e) {
      Logger.logError('Unexpected error for PUT $endpoint', e);
      throw ApiException('${ApiConstants.unknownErrorMessage}: $e');
    }
  }

  Future<Map<String, dynamic>> delete(
      String endpoint, {
        Map<String, String>? queryParameters,
      }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      Logger.logInfo('DELETE request to: $uri');

      final response = await _client.delete(
        uri,
        headers: ApiConstants.defaultHeaders,
      ).timeout(Duration(seconds: AppConfig.requestTimeout));

      return _handleResponse(response);
    } on TimeoutException {
      Logger.logError('Request timeout for DELETE $endpoint');
      throw ApiException(ApiConstants.timeoutErrorMessage);
    } on SocketException {
      Logger.logError('Network error for DELETE $endpoint');
      throw ApiException(ApiConstants.networkErrorMessage);
    } catch (e) {
      Logger.logError('Unexpected error for DELETE $endpoint', e);
      throw ApiException('${ApiConstants.unknownErrorMessage}: $e');
    }
  }

  Uri _buildUri(String endpoint, Map<String, String>? queryParameters) {
    final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');

    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(queryParameters: queryParameters);
    }

    return uri;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    Logger.logInfo('Response status: ${response.statusCode}');

    try {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Logger.logSuccess('Request successful');
        return data;
      } else {
        final errorMessage = data['message'] ?? _getStatusMessage(response.statusCode);
        Logger.logError('API error: $errorMessage (Status: ${response.statusCode})');
        throw ApiException(errorMessage, response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;

      Logger.logError('JSON parsing error', e);
      throw ApiException(ApiConstants.dataParsingErrorMessage);
    }
  }

  String _getStatusMessage(int statusCode) {
    switch (statusCode) {
      case ApiConstants.statusBadRequest:
        return 'Bad request';
      case ApiConstants.statusUnauthorized:
        return 'Unauthorized access';
      case ApiConstants.statusForbidden:
        return 'Access forbidden';
      case ApiConstants.statusNotFound:
        return 'Resource not found';
      case ApiConstants.statusInternalServerError:
        return ApiConstants.serverErrorMessage;
      case ApiConstants.statusBadGateway:
        return 'Bad gateway';
      case ApiConstants.statusServiceUnavailable:
        return 'Service unavailable';
      default:
        return ApiConstants.unknownErrorMessage;
    }
  }
}