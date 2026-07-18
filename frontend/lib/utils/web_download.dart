import 'dart:html' as html;
import 'dart:typed_data';

void triggerWebDownload(List<int> bytes, String mimeType, String filename) {
  final blob = html.Blob([Uint8List.fromList(bytes)], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
