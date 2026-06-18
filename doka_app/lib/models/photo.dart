  
 class Photo {
   final int? id;
   final String localPath;
   final String thumbnailPath;
   final DateTime createdAt;
   final double? latitude;
   final double? longitude;
   final String? filterName;
   final String? compositionType;
 
   Photo({
     this.id,
     required this.localPath,
     required this.thumbnailPath,
     required this.createdAt,
     this.latitude,
     this.longitude,
     this.filterName,
     this.compositionType,
   });
 
   Map<String, dynamic> toMap() => {
         'id': id,
         'localPath': localPath,
         'thumbnailPath': thumbnailPath,
         'createdAt': createdAt.toIso8601String(),
         'latitude': latitude,
         'longitude': longitude,
         'filterName': filterName,
         'compositionType': compositionType,
       };
 
   factory Photo.fromMap(Map<String, dynamic> map) => Photo(
         id: map['id'] as int?,
         localPath: map['localPath'] as String,
         thumbnailPath: map['thumbnailPath'] as String,
         createdAt: DateTime.parse(map['createdAt'] as String),
         latitude: map['latitude'] as double?,
         longitude: map['longitude'] as double?,
         filterName: map['filterName'] as String?,
         compositionType: map['compositionType'] as String?,
       );
 }
