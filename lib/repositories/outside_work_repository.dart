import 'package:dio/dio.dart';
import '../models/outside_work_request.dart';
import '../models/paginated_response.dart';
import '../services/barom_api.dart';

class CreateOutsideWorkResult {
  final OutsideWorkRequest? request;
  final bool autoApproved;

  const CreateOutsideWorkResult({this.request, this.autoApproved = false});
}

class OutsideWorkRepository {
  final BaromApi _api;

  OutsideWorkRepository() : _api = BaromApi();

  Future<PaginatedResponse<OutsideWorkRequest>> getMyRequests({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _api.dio.get(
      '/my-outside-work-requests',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      (item) => OutsideWorkRequest.fromJson(item as Map<String, dynamic>),
    );
  }

  Future<CreateOutsideWorkResult> createRequest({
    required String startDate,
    String? endDate,
    required String reason,
  }) async {
    try {
      final response = await _api.dio.post(
        '/my-outside-work-requests',
        data: {
          'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
          'reason': reason,
        },
      );
      final json = response.data as Map<String, dynamic>;
      return CreateOutsideWorkResult(
        request: json['data'] is Map<String, dynamic>
            ? OutsideWorkRequest.fromJson(json['data'] as Map<String, dynamic>)
            : null,
        autoApproved: json['auto_approved'] as bool? ?? false,
      );
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<void> cancelRequest(int id) async {
    try {
      await _api.dio.patch('/my-outside-work-requests/$id/cancel');
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  String _extractError(DioException e) {
    if (e.response?.data is Map) {
      final data = e.response!.data as Map<String, dynamic>;
      // Prefer the first field error (e.g. "start_date must be today or later")
      // over Laravel's generic summary message.
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty && first.first is String) {
          return first.first as String;
        }
      }
      return (data['message'] ?? data['error'] ?? e.toString()) as String;
    }
    return e.toString();
  }
}
