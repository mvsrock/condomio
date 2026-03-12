import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../config/keycloak_config.dart';
import '../../../utils/api_error.dart';
import '../../documents/domain/documento_download_model.dart';
import '../domain/async_job_model.dart';

/// API client per job asincroni lato core.
class AsyncJobApiClient {
  const AsyncJobApiClient();

  Uri _uri(String path) => Uri.parse('${KeycloakAppConfig.coreApiUrl}$path');

  Uri _uriWithQuery(String path, Map<String, String> queryParameters) =>
      _uri(path).replace(queryParameters: queryParameters);

  Map<String, String> _headers(String accessToken) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };

  Never _throwHttpError(String operation, http.Response response) {
    throw ApiError.fromHttp(operation: operation, response: response);
  }

  Future<List<AsyncJobModel>> listJobs({
    required String accessToken,
    int limit = 30,
  }) async {
    final response = await http.get(
      _uriWithQuery('/jobs', {'limit': '$limit'}),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('listAsyncJobs', response);
    }
    final list = (jsonDecode(response.body) as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(AsyncJobModel.fromJson)
        .toList(growable: false);
  }

  Future<AsyncJobModel> queueReportExport({
    required String accessToken,
    required String condominioId,
    required AsyncReportFormat format,
    String? condominoId,
  }) async {
    final query = <String, String>{
      'idCondominio': condominioId,
      'format': format.backendValue,
    };
    final normalizedCondominoId = _normalize(condominoId);
    if (normalizedCondominoId != null) {
      query['condominoId'] = normalizedCondominoId;
    }
    final response = await http.post(
      _uriWithQuery('/jobs/report-export', query),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('queueReportExportJob', response);
    }
    final raw =
        (jsonDecode(response.body) as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    return AsyncJobModel.fromJson(raw);
  }

  Future<AsyncJobModel> queueAutomaticSolleciti({
    required String accessToken,
    required String condominioId,
    required int minDaysOverdue,
  }) async {
    final response = await http.post(
      _uriWithQuery('/jobs/morosita/$condominioId/solleciti-automatici', {
        'minDaysOverdue': '$minDaysOverdue',
      }),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('queueAutoSollecitiJob', response);
    }
    final raw =
        (jsonDecode(response.body) as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    return AsyncJobModel.fromJson(raw);
  }

  Future<AsyncJobModel> queueUpcomingReminders({
    required String accessToken,
    required String condominioId,
    required int maxDaysAhead,
  }) async {
    final response = await http.post(
      _uriWithQuery('/jobs/morosita/$condominioId/reminder-scadenze', {
        'maxDaysAhead': '$maxDaysAhead',
      }),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('queueUpcomingReminderJob', response);
    }
    final raw =
        (jsonDecode(response.body) as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    return AsyncJobModel.fromJson(raw);
  }

  Future<DocumentoDownloadModel> downloadResult({
    required String accessToken,
    required String jobId,
  }) async {
    final response = await http.get(
      _uri('/jobs/$jobId/download'),
      headers: _headers(accessToken),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwHttpError('downloadAsyncJobResult', response);
    }
    final contentType =
        response.headers['content-type'] ?? 'application/octet-stream';
    final disposition = response.headers['content-disposition'] ?? '';
    final fileName =
        _extractFileNameFromDisposition(disposition) ?? 'job_result';
    return DocumentoDownloadModel(
      fileName: fileName,
      contentType: contentType,
      bytes: response.bodyBytes,
    );
  }

  String? _normalize(String? value) {
    if (value == null) return null;
    final out = value.trim();
    return out.isEmpty ? null : out;
  }

  String? _extractFileNameFromDisposition(String disposition) {
    if (disposition.trim().isEmpty) return null;
    final starMatch = RegExp(
      r'filename\*\s*=\s*([^;]+)',
      caseSensitive: false,
    ).firstMatch(disposition);
    if (starMatch != null) {
      var raw = (starMatch.group(1) ?? '').trim().replaceAll('"', '');
      final lower = raw.toLowerCase();
      if (lower.startsWith("utf-8''")) {
        raw = raw.substring(7);
      }
      final decoded = Uri.decodeComponent(raw).trim();
      final sanitized = _sanitizeFileName(decoded);
      if (sanitized != null) return sanitized;
    }

    final plainQuoted = RegExp(
      r'filename\s*=\s*"([^"]+)"',
      caseSensitive: false,
    ).firstMatch(disposition);
    if (plainQuoted != null) {
      final sanitized = _sanitizeFileName((plainQuoted.group(1) ?? '').trim());
      if (sanitized != null) return sanitized;
    }
    final plainRaw = RegExp(
      r'filename\s*=\s*([^;]+)',
      caseSensitive: false,
    ).firstMatch(disposition);
    if (plainRaw != null) {
      final sanitized = _sanitizeFileName(
        (plainRaw.group(1) ?? '').trim().replaceAll('"', ''),
      );
      if (sanitized != null) return sanitized;
    }
    return null;
  }

  String? _sanitizeFileName(String raw) {
    if (raw.isEmpty) return null;
    var value = raw;
    value = value.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_');
    value = value.trim().replaceAll(RegExp(r'[. ]+$'), '');
    if (value.isEmpty) return null;
    return value;
  }
}
