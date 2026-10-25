import 'package:cortex/capture/drop_reader.dart';
import 'package:cortex/data/models/research_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stripHtml keeps paragraph text', () {
    final out = stripHtml('<p>Hello <b>world</b></p><br/>Next');
    expect(out.contains('Hello'), isTrue);
    expect(out.contains('world'), isTrue);
    expect(out.contains('<'), isFalse);
  });

  test('classifyAndSaveText routes http to link', () {
    final p = classifyAndSaveText('https://example.com/a');
    expect(p.type, ItemType.link);
    expect(p.sourceUrl, 'https://example.com/a');
  });

  test('classifyAndSaveText routes prose to text', () {
    final p = classifyAndSaveText('Research note about foldables');
    expect(p.type, ItemType.text);
    expect(p.text, 'Research note about foldables');
  });
}
