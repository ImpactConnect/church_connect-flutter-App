import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service.dart';

class ServiceRepository {
  final SupabaseClient _supabase;
  static const String _tableName = 'church_services';

  ServiceRepository(this._supabase);

  Future<List<ChurchService>> getUpcomingServices() async {
    final response = await _supabase
        .from(_tableName)
        .select()
        .gt('service_date', DateTime.now().toIso8601String())
        .order('service_date')
        .limit(5)
        .execute();

    if (response.error != null) {
      throw response.error!;
    }

    return (response.data as List)
        .map((json) => ChurchService.fromJson(json))
        .toList();
  }

  Future<ChurchService?> getNextService() async {
    final response = await _supabase
        .from(_tableName)
        .select()
        .gt('service_date', DateTime.now().toIso8601String())
        .order('service_date')
        .limit(1)
        .single()
        .execute();

    if (response.error != null) {
      if (response.error!.message.contains('Row not found')) {
        return null;
      }
      throw response.error!;
    }

    return ChurchService.fromJson(response.data);
  }

  Future<void> addService(ChurchService service) async {
    final response = await _supabase.from(_tableName).insert(service.toJson()).execute();

    if (response.error != null) {
      throw response.error!;
    }
  }

  Future<void> updateService(ChurchService service) async {
    final response = await _supabase
        .from(_tableName)
        .update(service.toJson())
        .eq('id', service.id)
        .execute();

    if (response.error != null) {
      throw response.error!;
    }
  }

  Future<void> deleteService(int id) async {
    final response = await _supabase.from(_tableName).delete().eq('id', id).execute();

    if (response.error != null) {
      throw response.error!;
    }
  }
}
