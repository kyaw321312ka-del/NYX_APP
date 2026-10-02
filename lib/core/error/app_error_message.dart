import 'dart:async';
import 'dart:io';

import 'package:nyxproject/core/error/api_exception.dart';

class AppErrorMessage {
  static String from(Object? error) {
    if (error is ApiException) {
      switch (error.statusCode) {
        case 401:
          return 'Your session has expired. Please sign in again.';
        case 403:
          return 'You do not have permission to do that.';
        case 404:
          return 'The requested information is no longer available.';
        case 408:
          return 'The request took too long. Please try again.';
        case 429:
          return 'Too many requests. Please wait a moment and try again.';
      }
      if (error.statusCode != null && error.statusCode! >= 500) {
        return 'The server is having trouble. Please try again shortly.';
      }
      return error.message.isNotEmpty
          ? error.message
          : 'We could not complete your request. Please try again.';
    }

    if (error is SocketException || error is HttpException) {
      return 'Unable to connect. Check your internet connection and try again.';
    }
    if (error is TimeoutException) {
      return 'The request took too long. Please try again.';
    }
    if (error is FormatException) {
      return 'We received an unexpected response. Please try again later.';
    }
    if (error is String) {
      final message = error.trim();
      final normalized = message.toLowerCase();
      if (normalized.contains('socketexception') ||
          normalized.contains('failed host lookup') ||
          normalized.contains('connection refused') ||
          normalized.contains('connection timed out')) {
        return 'Unable to connect. Check your internet connection and try again.';
      }
      if (normalized.contains('timeoutexception') ||
          normalized.contains('timed out')) {
        return 'The request took too long. Please try again.';
      }
      if (message.isNotEmpty) return message;
    }

    return 'Something went wrong. Please try again.';
  }
}
