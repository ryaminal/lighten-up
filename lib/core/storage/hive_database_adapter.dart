import 'package:hive_flutter/hive_flutter.dart';
import 'package:lighten_up/core/storage/database_interface.dart';

/// Hive adapter implementing IDatabase interface
/// Wraps Hive to match our interface - easy to swap or mock
class HiveDatabaseAdapter implements IDatabase {
  bool _initialized = false;
  final Set<String> _openedBoxes = {};

  @override
  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _initialized = true;
  }

  @override
  Future<void> close() async {
    await Hive.close();
    _initialized = false;
    _openedBoxes.clear();
  }

  @override
  Future<IDatabaseBox<T>> openBox<T>(String name) async {
    final box = await Hive.openBox<T>(name);
    _openedBoxes.add(name);
    return HiveBoxAdapter<T>(box);
  }

  @override
  Future<void> deleteBox(String name) async {
    if (await boxExists(name)) {
      await Hive.deleteBoxFromDisk(name);
      _openedBoxes.remove(name);
    }
  }

  @override
  Future<bool> boxExists(String name) async {
    return Hive.isBoxOpen(name) || await Hive.boxExists(name);
  }

  @override
  Future<void> clearAll() async {
    for (final name in _openedBoxes) {
      final box = await Hive.openBox(name);
      await box.clear();
    }
  }
}

/// Hive box adapter implementing IDatabaseBox interface
class HiveBoxAdapter<T> implements IDatabaseBox<T> {
  final Box<T> _box;

  HiveBoxAdapter(this._box);

  @override
  Future<T?> get(String key) async {
    return _box.get(key);
  }

  @override
  Future<void> put(String key, T value) async {
    await _box.put(key, value);
  }

  @override
  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  @override
  Future<List<T>> getAll() async {
    return _box.values.toList();
  }

  @override
  Future<List<String>> getAllKeys() async {
    return _box.keys.map((e) => e.toString()).toList();
  }

  @override
  Future<bool> containsKey(String key) async {
    return _box.containsKey(key);
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }

  @override
  Future<int> length() async {
    return _box.length;
  }

  @override
  Future<void> close() async {
    await _box.close();
  }
}
