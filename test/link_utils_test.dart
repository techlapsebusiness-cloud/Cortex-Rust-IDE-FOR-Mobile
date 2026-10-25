import 'package:cortex/data/enrichment/link_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses watch?v=', () {
    expect(
      LinkUtils.youtubeVideoId('https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
      'dQw4w9WgXcQ',
    );
  });

  test('parses youtu.be', () {
    expect(
      LinkUtils.youtubeVideoId('https://youtu.be/dQw4w9WgXcQ?t=12'),
      'dQw4w9WgXcQ',
    );
  });

  test('parses shorts', () {
    expect(
      LinkUtils.youtubeVideoId('https://youtube.com/shorts/dQw4w9WgXcQ'),
      'dQw4w9WgXcQ',
    );
  });

  test('rejects non-youtube', () {
    expect(LinkUtils.youtubeVideoId('https://example.com/watch?v=x'), isNull);
  });
}
