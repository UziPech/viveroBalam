import 'package:hive/hive.dart';
import '../../domain/entities/artesania.dart';

/// Repositorio para operaciones CRUD de artesanías
class ArtesaniaRepository {
  final Box<Artesania> _box;

  ArtesaniaRepository(this._box);

  // ==================== CREATE ====================
  
  Future<void> saveArtesania(Artesania artesania) async {
    await _box.add(artesania);
  }

  // ==================== READ ====================
  
  List<Artesania> getAllArtesanias() {
    return _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Artesania? getArtesaniaByKey(dynamic key) {
    return _box.get(key);
  }

  Stream<List<Artesania>> watchAllArtesanias() async* {
    yield getAllArtesanias();
    await for (final _ in _box.watch()) {
      yield getAllArtesanias();
    }
  }

  // ==================== UPDATE ====================
  
  Future<void> updateArtesania(Artesania artesania) async {
    if (artesania.key != null) {
      await _box.put(artesania.key, artesania);
    }
  }

  // ==================== DELETE ====================
  
  Future<void> deleteArtesania(Artesania artesania) async {
    await _box.delete(artesania.key);
  }

  // ==================== STATS ====================
  
  int get totalArtesanias => _box.length;

  double get valorTotal => _box.values.fold(0, (sum, a) => sum + a.precio);
}
