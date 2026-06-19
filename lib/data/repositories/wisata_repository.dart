
// ─── lib/data/repositories/wisata_repository.dart ─────────────
import '../../core/network/api_service.dart';
// removed unused import '../models/all_models.dart'
import '../models/kategori_model.dart';
import '../models/paket_camping_model.dart';
import '../models/penginapan_model.dart';
import '../models/peralatan_model.dart';
import '../models/wisata_model.dart' show WisataModel;
 
class WisataRepository {
  final ApiService _api = ApiService();
 
  Future<Map<String, dynamic>> getWisata({
    String? search, int? kategoriId, String? sort, int page = 1,
  }) async {
    try {
      final res = await _api.getWisata(search: search, kategoriId: kategoriId, sort: sort, page: page);
      final data = res.data['data'];
      final List list = data['data'] ?? data ?? [];
      return {
        'success': true,
        'data': list.map((w) => WisataModel.fromJson(w)).toList(),
        'total': data['total'] ?? list.length,
        'current_page': data['current_page'] ?? 1,
        'last_page': data['last_page'] ?? 1,
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat data wisata.', 'data': <WisataModel>[]};
    }
  }
 
  Future<WisataModel?> getDetail(int id) async {
    try {
      final res = await _api.getWisataDetail(id);
      if (res.data['success'] == true) return WisataModel.fromJson(res.data['data']);
    } catch (_) {}
    return null;
  }
 
  Future<List<KategoriModel>> getKategori() async {
    try {
      final res = await _api.getKategori();
      final list = res.data['data'] as List;
      return list.map((k) => KategoriModel.fromJson(k)).toList();
    } catch (_) {
      return [];
    }
  }
 
  Future<List<PaketCampingModel>> getPaketCamping(int wisataId) async {
    try {
      final res = await _api.getPaketCampingPublic(wisataId);
      final list = res.data['data'] as List;
      return list.map((p) => PaketCampingModel.fromJson(p)).toList();
    } catch (_) {
      return [];
    }
  }
 
  Future<List<PenginapanModel>> getPenginapan(int wisataId) async {
    try {
      final res = await _api.getPenginapanPublic(wisataId);
      final list = res.data['data'] as List;
      return list.map((p) => PenginapanModel.fromJson(p)).toList();
    } catch (_) {
      return [];
    }
  }
 
  Future<List<PeralatanModel>> getPeralatan(int wisataId, {String? mulai, String? selesai}) async {
    try {
      final res = await _api.getPeralatanPublic(wisataId, mulai: mulai, selesai: selesai);
      final list = res.data['data'] as List;
      return list.map((p) => PeralatanModel.fromJson(p)).toList();
    } catch (_) {
      return [];
    }
  }
}