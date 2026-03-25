import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting task creation drafts locally.
class DraftService {
  static const String _draftKeyPrefix = 'task_draft_';
  // Use a special id 'new' for creation drafts, otherwise use the task id for edit drafts
  
  final SharedPreferences _prefs;

  DraftService(this._prefs);

  /// Initialize the service
  static Future<DraftService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return DraftService(prefs);
  }

  /// Save draft data for a given form (create or edit)
  Future<bool> saveDraft(String taskId, Map<String, dynamic> draftData) async {
    try {
      final jsonString = json.encode(draftData);
      return await _prefs.setString('$_draftKeyPrefix$taskId', jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Load draft data for a given form
  Map<String, dynamic>? loadDraft(String taskId) {
    try {
      final jsonString = _prefs.getString('$_draftKeyPrefix$taskId');
      if (jsonString != null) {
        return json.decode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {}
    return null;
  }

  /// Clear a specific draft
  Future<bool> clearDraft(String taskId) async {
    return await _prefs.remove('$_draftKeyPrefix$taskId');
  }
}
