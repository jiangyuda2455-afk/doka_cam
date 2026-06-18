import 'lut_generator.dart';
import 'lut_processor.dart';
import '../../models/filter_preset.dart';

class LutLibrary {
  final Map<String, LutProcessor> _cache = {};

  LutProcessor? getFilter(FilterPreset filter) {
    if (filter.name == 'normal') return null;
    if (_cache.containsKey(filter.name)) return _cache[filter.name];

    // Try to load .cube file first, fall back to generated LUT
    final data = _loadCubeFile(filter.lutFileName) ?? LutGenerator.generate(filter);
    final processor = LutProcessor(data);
    _cache[filter.name] = processor;
    return processor;
  }

  List<double>? _loadCubeFile(String fileName) {
    if (fileName.isEmpty) return null;
    // Placeholder: in production, load from assets/luts/
    return null;
  }

  void dispose() => _cache.clear();
}

