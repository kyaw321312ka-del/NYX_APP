import 'package:flutter/painting.dart' show WebHtmlElementStrategy;
import 'package:flutter_test/flutter_test.dart';
import 'package:nyxproject/core/presentation/widgets/cors_safe_network_image.dart';

void main() {
  test(
    'network providers prefer browser image elements for cross-origin URLs',
    () {
      final provider = CorsSafeNetworkImage.provider(
        'http://example.test/image.png',
      );

      expect(provider.webHtmlElementStrategy, WebHtmlElementStrategy.prefer);
    },
  );
}
