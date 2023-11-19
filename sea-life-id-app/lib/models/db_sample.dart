import 'package:file_picker/file_picker.dart';
import 'package:underwater_video_tagging/models/media_model.dart';

class DbSample {
  DbSample({required this.id, required this.url, required this.tags});

  DbSample.fromJson(String id, Map<String, Object?> json)
      : this(
            id: id,
            url: json['url']! as String,
            tags: (json['tags']! as List).cast<String>());

  Map<String, Object?> toJson() {
    return {'url': url, 'tags': tags};
  }

  MediaModel toMedia() {
    MediaModel mm = MediaModel(
        fileName: id,
        fileType: getFileType(),
        path: url,
        isLocal: false,
        isDbSample: true);
    tags.forEach((element) {
      mm.addTag(element);
    });
    return mm;
  }

  FileType getFileType() {
    if (this.url.contains(".mp4")) {
      return FileType.video;
    } else {
      return FileType.image;
    }
  }

  isVideo() {
    if (this.url.contains(".mp4")) {
      return true;
    } else {
      return false;
    }
  }

  final String id;
  final String url;
  final List<String> tags;

  @override
  String toString() => "id=$id, tags=$tags isVideo=${isVideo()}";
}
