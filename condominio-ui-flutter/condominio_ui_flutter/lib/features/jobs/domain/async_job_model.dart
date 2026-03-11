enum AsyncJobType { reportExport, morositaAutoSolleciti, unknown }

enum AsyncJobStatus { queued, running, done, failed, unknown }

class AsyncJobModel {
  const AsyncJobModel({
    required this.id,
    required this.idCondominio,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.startedAt,
    required this.finishedAt,
    required this.inputFormat,
    required this.inputCondominoId,
    required this.inputMinDaysOverdue,
    required this.resultFileName,
    required this.resultContentType,
    required this.resultSizeBytes,
    required this.resultCount,
    required this.message,
    required this.errorCode,
    required this.resultDownloadAvailable,
  });

  final String id;
  final String idCondominio;
  final AsyncJobType type;
  final AsyncJobStatus status;
  final DateTime? createdAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final String? inputFormat;
  final String? inputCondominoId;
  final int? inputMinDaysOverdue;
  final String? resultFileName;
  final String? resultContentType;
  final int? resultSizeBytes;
  final int? resultCount;
  final String? message;
  final String? errorCode;
  final bool resultDownloadAvailable;

  bool get isTerminal =>
      status == AsyncJobStatus.done || status == AsyncJobStatus.failed;

  factory AsyncJobModel.fromJson(Map<String, dynamic> json) {
    return AsyncJobModel(
      id: json['id'] as String? ?? '',
      idCondominio: json['idCondominio'] as String? ?? '',
      type: _parseType(json['type'] as String?),
      status: _parseStatus(json['status'] as String?),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? ''),
      finishedAt: DateTime.tryParse(json['finishedAt'] as String? ?? ''),
      inputFormat: json['inputFormat'] as String?,
      inputCondominoId: json['inputCondominoId'] as String?,
      inputMinDaysOverdue: (json['inputMinDaysOverdue'] as num?)?.toInt(),
      resultFileName: json['resultFileName'] as String?,
      resultContentType: json['resultContentType'] as String?,
      resultSizeBytes: (json['resultSizeBytes'] as num?)?.toInt(),
      resultCount: (json['resultCount'] as num?)?.toInt(),
      message: json['message'] as String?,
      errorCode: json['errorCode'] as String?,
      resultDownloadAvailable: json['resultDownloadAvailable'] == true,
    );
  }

  static AsyncJobType _parseType(String? value) {
    switch ((value ?? '').trim().toUpperCase()) {
      case 'REPORT_EXPORT':
        return AsyncJobType.reportExport;
      case 'MOROSITA_AUTO_SOLLECITI':
        return AsyncJobType.morositaAutoSolleciti;
      default:
        return AsyncJobType.unknown;
    }
  }

  static AsyncJobStatus _parseStatus(String? value) {
    switch ((value ?? '').trim().toUpperCase()) {
      case 'QUEUED':
        return AsyncJobStatus.queued;
      case 'RUNNING':
        return AsyncJobStatus.running;
      case 'DONE':
        return AsyncJobStatus.done;
      case 'FAILED':
        return AsyncJobStatus.failed;
      default:
        return AsyncJobStatus.unknown;
    }
  }
}

enum AsyncReportFormat { pdf, xlsx }

extension AsyncReportFormatX on AsyncReportFormat {
  String get backendValue {
    switch (this) {
      case AsyncReportFormat.pdf:
        return 'pdf';
      case AsyncReportFormat.xlsx:
        return 'xlsx';
    }
  }
}
