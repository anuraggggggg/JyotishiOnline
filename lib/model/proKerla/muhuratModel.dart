import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';

class AuspiciousResponse {
  final String status;
  final AuspiciousData data;

  AuspiciousResponse({required this.status, required this.data});

  factory AuspiciousResponse.fromJson(Map<String, dynamic> json) {
    // First, handle the case where json might be null
    if (json == null) {
      throw FormatException('Response JSON is null');
    }

    // Safely extract and validate status
    final status = json['status']?.toString().toLowerCase();
    if (status == null) {
      print('Full API response: $json'); // Log the full response for debugging
      throw FormatException('API status field is missing in response');
    }
    if (status != 'ok') {
      throw FormatException('API returned non-ok status: $status');
    }

    // Safely extract and validate data
    final dataJson = json['data'];
    if (dataJson == null) {
      throw FormatException('Missing data field in API response');
    }
    if (dataJson is! Map<String, dynamic>) {
      throw FormatException('Data field is not a Map');
    }

    return AuspiciousResponse(
      status: status,
      data: AuspiciousData.fromJson(dataJson),
    );
  }
}

class AuspiciousData {
  final List<Muhurat> muhurat;

  AuspiciousData({required this.muhurat});

  factory AuspiciousData.fromJson(Map<String, dynamic> json) {
    try {
      final muhuratList = json['muhurat'] as List?;
      return AuspiciousData(
        muhurat: muhuratList?.map((item) {
          try {
            return Muhurat.fromJson(item as Map<String, dynamic>);
          } catch (e) {
            throw FormatException('Failed to parse Muhurat item: $e');
          }
        }).toList() ?? [],
      );
    } catch (e) {
      throw FormatException('Failed to parse AuspiciousData: $e');
    }
  }
}

class Muhurat {
  final int? id;
  final String? name;
  final String? type;
  final List<Period> periods;

  Muhurat({
    this.id,
    this.name,
    this.type,
    required this.periods,
  });

  String get displayName => name?.trim() ?? 'unnamed_muhurat'.tr();

  factory Muhurat.fromJson(Map<String, dynamic> json) {
    try {
      final periodList = json['period'] as List?;
      return Muhurat(
        id: _parseInt(json['id']),
        name: json['name']?.toString(),
        type: json['type']?.toString(),
        periods: periodList?.map((period) {
          try {
            return Period.fromJson(period as Map<String, dynamic>);
          } catch (e) {
            throw FormatException('Failed to parse Period: $e');
          }
        }).toList() ?? [],
      );
    } catch (e) {
      throw FormatException('Failed to parse Muhurat: $e');
    }
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class Period {
  final DateTime start;
  final DateTime end;

  Period({required this.start, required this.end});

  factory Period.fromJson(Map<String, dynamic> json) {
    try {
      final startStr = json['start']?.toString();
      final endStr = json['end']?.toString();

      if (startStr == null || endStr == null) {
        throw FormatException('Missing start or end time');
      }

      return Period(
        start: DateTime.parse(startStr).toLocal(),
        end: DateTime.parse(endStr).toLocal(),
      );
    } catch (e) {
      throw FormatException('Failed to parse Period: $e');
    }
  }

  String formattedTimeRange({bool use24Hour = false}) {
    try {
      final format = use24Hour ? 'HH:mm' : 'hh:mm a';
      return '${DateFormat(format).format(start)} - ${DateFormat(format).format(end)}';
    } catch (e) {
      return 'invalid_time_format'.tr();
    }
  }

  String get duration {
    try {
      final difference = end.difference(start);
      final hours = difference.inHours;
      final minutes = difference.inMinutes.remainder(60);

      if (hours > 0) {
        return '${hours}h ${minutes}m';
      }
      return '${minutes}m';
    } catch (e) {
      return 'invalid_duration'.tr();
    }
  }
}