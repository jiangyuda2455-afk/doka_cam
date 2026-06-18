  
 class FilterPreset {
   final String name;
   final String displayName;
   final String lutFileName;
   final List<String> tags;
   final double defaultStrength;
 
   const FilterPreset({
     required this.name,
     required this.displayName,
     required this.lutFileName,
     this.tags = const [],
     this.defaultStrength = 1.0,
   });
 
   static const List<FilterPreset> builtIn = [
     FilterPreset(
       name: 'normal',
       displayName: '鍘熺墖',
       lutFileName: '',
       tags: ['default'],
     ),
     FilterPreset(
       name: 'fuji_pro_400h',
       displayName: 'Fuji Pro 400H',
       lutFileName: 'fuji_pro_400h.cube',
       tags: ['portrait', 'warm'],
       defaultStrength: 0.85,
     ),
     FilterPreset(
       name: 'fuji_classic_chrome',
       displayName: 'Fuji Classic Chrome',
       lutFileName: 'fuji_classic_chrome.cube',
       tags: ['street', 'architecture'],
       defaultStrength: 0.9,
     ),
     FilterPreset(
       name: 'kodak_portra_160',
       displayName: 'Kodak Portra 160',
       lutFileName: 'kodak_portra_160.cube',
       tags: ['portrait', 'soft'],
       defaultStrength: 0.8,
     ),
     FilterPreset(
       name: 'kodak_portra_400',
       displayName: 'Kodak Portra 400',
       lutFileName: 'kodak_portra_400.cube',
       tags: ['portrait', 'everyday'],
       defaultStrength: 0.85,
     ),
     FilterPreset(
       name: 'kodak_gold',
       displayName: 'Kodak Gold',
       lutFileName: 'kodak_gold.cube',
       tags: ['landscape', 'vintage'],
       defaultStrength: 0.9,
     ),
     FilterPreset(
       name: 'agfa_vista',
       displayName: 'Agfa Vista',
       lutFileName: 'agfa_vista.cube',
       tags: ['landscape', 'cool'],
       defaultStrength: 0.85,
     ),
     FilterPreset(
       name: 'bw_classic',
       displayName: '榛戠櫧鑳剁墖',
       lutFileName: 'bw_classic.cube',
       tags: ['bw', 'street', 'portrait'],
       defaultStrength: 1.0,
     ),
     FilterPreset(
       name: 'expired_film',
       displayName: '杩囨湡鑳跺嵎',
       lutFileName: 'expired_film.cube',
       tags: ['vintage', 'creative'],
       defaultStrength: 0.75,
     ),
   ];
 
   static const Map<String, List<String>> sceneRecommendations = {
     'architecture': ['fuji_classic_chrome', 'bw_classic'],
     'landscape': ['kodak_gold', 'agfa_vista'],
     'portrait': ['fuji_pro_400h', 'kodak_portra_160', 'kodak_portra_400'],
     'food': ['fuji_pro_400h', 'kodak_gold'],
     'street': ['fuji_classic_chrome', 'bw_classic'],
     'night': ['kodak_portra_400', 'expired_film'],
     'indoor': ['kodak_portra_160', 'fuji_pro_400h'],
   };
 }
