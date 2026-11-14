import 'package:flutter_test/flutter_test.dart';
import 'package:nyxproject/core/error/api_exception.dart';
import 'package:nyxproject/core/error/app_error_message.dart';

void main() {
  test('hides API URLs from wrapped offline errors', () {
    final message = AppErrorMessage.from(
      const ApiException(
        'Network error: ClientException: Failed to fetch, '
        'uri=http://192.168.1.10:8000/api/homecategory/showproduct',
      ),
    );

    expect(
      message,
      'Unable to connect. Check your internet connection and try again.',
    );
    expect(message, isNot(contains('192.168.1.10')));
  });
}
