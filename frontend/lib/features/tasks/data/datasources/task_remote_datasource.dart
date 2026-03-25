import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/task_model.dart';

/// Remote data source for tasks - communicates with the FastAPI backend.
class TaskRemoteDataSource {
  final http.Client client;

  TaskRemoteDataSource({required this.client});

  Future<List<TaskModel>> getTasks({String? search, String? status}) async {
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.tasksEndpoint}/',
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    try {
      final response = await client
          .get(uri)
          .timeout(ApiConstants.timeoutDuration);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => TaskModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: 'Failed to fetch tasks',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  Future<TaskModel> createTask(Map<String, dynamic> taskData) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.tasksEndpoint}/',
    );
    try {
      final response = await client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(taskData),
          )
          .timeout(ApiConstants.timeoutDuration);
      if (response.statusCode == 201) {
        return TaskModel.fromJson(json.decode(response.body));
      } else {
        final body = json.decode(response.body);
        throw ServerException(
          message: body['detail'] ?? 'Failed to create task',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  Future<TaskModel> updateTask(String id, Map<String, dynamic> taskData) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.tasksEndpoint}/$id',
    );
    try {
      final response = await client
          .put(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(taskData),
          )
          .timeout(ApiConstants.timeoutDuration);
      if (response.statusCode == 200) {
        return TaskModel.fromJson(json.decode(response.body));
      } else {
        final body = json.decode(response.body);
        throw ServerException(
          message: body['detail'] ?? 'Failed to update task',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  Future<void> deleteTask(String id) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.tasksEndpoint}/$id',
    );
    try {
      final response = await client
          .delete(uri)
          .timeout(ApiConstants.timeoutDuration);
      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to delete task',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }
}
