import 'dart:io';

/// Lightweight local static server for previewing the portfolio website and
/// bundled Flutter Web ATS Resume Builder without extra dependencies.
///
/// Usage: `dart run serve.dart` (then open http://localhost:5000/)
Future<void> main(List<String> args) async {
  final port = args.isNotEmpty ? int.tryParse(args.first) ?? 5000 : 5000;
  final rootDir = Directory.current;
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);

  stdout.writeln('Serving ${rootDir.path}');
  stdout.writeln('  Portfolio Website : http://localhost:$port/');
  stdout.writeln('  ATS Resume Builder: http://localhost:$port/resume-builder/');
  stdout.writeln('Press Ctrl+C to stop.');

  await for (final request in server) {
    var path = Uri.decodeComponent(request.uri.path);
    if (path.endsWith('/')) {
      path = '${path}index.html';
    }

    final safePath = path.startsWith('/') ? path.substring(1) : path;
    var file = File('${rootDir.path}${Platform.pathSeparator}$safePath');
    if (Directory(file.path).existsSync()) {
      file = File('${file.path}${Platform.pathSeparator}index.html');
    }

    if (!file.existsSync()) {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write('404 Not Found: $path');
      await request.response.close();
      continue;
    }

    request.response.headers.contentType = _contentTypeFor(file.path);
    await file.openRead().pipe(request.response);
  }
}

ContentType _contentTypeFor(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.html')) return ContentType.html;
  if (lower.endsWith('.css')) return ContentType('text', 'css', charset: 'utf-8');
  if (lower.endsWith('.js') || lower.endsWith('.mjs')) {
    return ContentType('application', 'javascript', charset: 'utf-8');
  }
  if (lower.endsWith('.json')) return ContentType.json;
  if (lower.endsWith('.pdf')) return ContentType('application', 'pdf');
  if (lower.endsWith('.wasm')) return ContentType('application', 'wasm');
  if (lower.endsWith('.svg')) return ContentType('image', 'svg+xml');
  if (lower.endsWith('.png')) return ContentType('image', 'png');
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
    return ContentType('image', 'jpeg');
  }
  if (lower.endsWith('.ico')) return ContentType('image', 'x-icon');
  if (lower.endsWith('.ttf')) return ContentType('font', 'ttf');
  if (lower.endsWith('.otf')) return ContentType('font', 'otf');
  if (lower.endsWith('.woff2')) return ContentType('font', 'woff2');
  return ContentType.binary;
}
