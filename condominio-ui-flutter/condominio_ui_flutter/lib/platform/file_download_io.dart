import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

/// Salvataggio locale su target IO (desktop/mobile dove supportato).
Future<bool> saveBytesToFile({
  required Uint8List bytes,
  required String fileName,
  required String contentType,
}) async {
  final safeName = _sanitizeWindowsFileName(fileName);
  final ext = _extractExt(safeName);
  final outputPath = await FilePicker.platform.saveFile(
    dialogTitle: 'Salva file',
    fileName: safeName,
    type: ext == null ? FileType.any : FileType.custom,
    allowedExtensions: ext == null ? null : <String>[ext],
  );
  if (outputPath == null || outputPath.trim().isEmpty) {
    return false;
  }
  await File(outputPath).writeAsBytes(bytes, flush: true);
  return true;
}

String? _extractExt(String fileName) {
  final clean = fileName.trim();
  final dot = clean.lastIndexOf('.');
  if (dot <= 0 || dot == clean.length - 1) {
    return null;
  }
  return clean.substring(dot + 1).toLowerCase();
}

String _sanitizeWindowsFileName(String fileName) {
  var name = fileName.trim();
  if (name.isEmpty) {
    return 'download.bin';
  }
  name = name.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_');
  name = name.replaceAll(RegExp(r'[. ]+$'), '');
  if (name.isEmpty) {
    return 'download.bin';
  }
  final dot = name.lastIndexOf('.');
  final base = (dot > 0 ? name.substring(0, dot) : name).toUpperCase();
  const reserved = <String>{
    'CON',
    'PRN',
    'AUX',
    'NUL',
    'COM1',
    'COM2',
    'COM3',
    'COM4',
    'COM5',
    'COM6',
    'COM7',
    'COM8',
    'COM9',
    'LPT1',
    'LPT2',
    'LPT3',
    'LPT4',
    'LPT5',
    'LPT6',
    'LPT7',
    'LPT8',
    'LPT9',
  };
  if (reserved.contains(base)) {
    return '_$name';
  }
  return name;
}
