import '../models/checklist_item_model.dart';
import 'supabase_service.dart';

class ChecklistService {
  final _supabase = SupabaseService();

  Future<List<ChecklistItemModel>> getChecklistByEmployee(String employeeUid) async {
    return await _supabase.getChecklistByEmployee(employeeUid);
  }

  Future<bool> createChecklistItem(ChecklistItemModel item) async {
    return await _supabase.createChecklistItem(item);
  }

  Future<bool> updateChecklistItem(ChecklistItemModel item) async {
    return await _supabase.updateChecklistItem(item);
  }

  Future<bool> deleteChecklistItem(String itemId) async {
    return await _supabase.deleteChecklistItem(itemId);
  }
}
