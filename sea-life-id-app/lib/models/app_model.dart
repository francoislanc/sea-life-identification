import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:underwater_video_tagging/models/db_sample.dart';
import 'package:underwater_video_tagging/models/media_model.dart';
import 'package:mobx/mobx.dart';
import 'package:underwater_video_tagging/utils/automatic_tagging_utils.dart';
import 'package:underwater_video_tagging/utils/firebase_storage_utils.dart';

part 'app_model.g.dart';

class AppModel = AppModelBase with _$AppModel;

abstract class AppModelBase with Store {
  @observable
  ObservableList<MediaModel> userMedias = ObservableList();

  @observable
  ObservableList<MediaModel> galleryMedias = ObservableList();

  @observable
  ObservableList<String> selectedTags = ObservableList();

  @observable
  int galleryElementsNumber = 6;

  @action
  void showMoreGalleryElements() {
    if (galleryElementsNumber < galleryMedias.length) {
      galleryElementsNumber += 1;
    }
  }

  @computed
  ObservableList<MediaModel> get selectedGalleryMedias {
    List<MediaModel> lmm = galleryMedias.where((element) {
      return selectedTags.length == 0 ||
          element.tags.any((item) => selectedTags.contains(item));
    }).toList();

    lmm.shuffle();

    // final maxSize =
    //     lmm.length > galleryElementsNumber ? galleryElementsNumber : lmm.length;
    // final res = lmm.sublist(0, maxSize);
    return ObservableList<MediaModel>.of(lmm);
  }

  @observable
  bool galleryInitialized = false;

  @observable
  bool appInitialized = false;

  @observable
  bool modelInitialized = false;

  @action
  void addUserMedia(MediaModel item) {
    userMedias.add(item);
  }

  @action
  void addGalleryMedia(MediaModel item) {
    galleryMedias.add(item);
  }

  @action
  void removeUserMediaAt(int index) {
    userMedias.removeAt(index);
  }

  @action
  void removeUserMediaWithPath(String path) {
    userMedias.removeWhere((item) => item.path == path);
  }

  @action
  void replaceTags(List<Object?> tags) {
    selectedTags.clear();
    tags.forEach((element) {
      if (element is String) {
        selectedTags.add(element);
      }
    });
  }

  @action
  Future<void> initialize() async {
    modelInitialized = await FirebaseStorageUtils.initModel();
    await AutomaticTagging.deleteAppTmpFolder();
    await AutomaticTagging.initLabeler();

    FirebaseFirestore.instance.settings = Settings(persistenceEnabled: false);

    var galleryRef = FirebaseFirestore.instance
        .collection('gallery')
        .orderBy('order')
        .withConverter<DbSample>(
          fromFirestore: (snapshots, _) =>
              DbSample.fromJson(snapshots.id, snapshots.data()!),
          toFirestore: (dbsample, _) => dbsample.toJson(),
        );

    QuerySnapshot<DbSample> snapshot = await galleryRef.get();

    snapshot.docs.forEach((doc) async {
      MediaModel mm = doc.data().toMedia();
      await mm.createThumbnail();
      addGalleryMedia(mm);
    });

    var videoGalleryRef = FirebaseFirestore.instance
        .collection('video_gallery')
        .orderBy('order')
        .withConverter<DbSample>(
          fromFirestore: (snapshots, _) =>
              DbSample.fromJson(snapshots.id, snapshots.data()!),
          toFirestore: (dbsample, _) => dbsample.toJson(),
        );

    QuerySnapshot<DbSample> snapshotVideo = await videoGalleryRef.get();

    snapshotVideo.docs.forEach((doc) async {
      MediaModel mm = doc.data().toMedia();
      await mm.createThumbnail();
      addGalleryMedia(mm);
    });

    reaction((_) => userMedias.length, (userMediasLength) async {
      if (userMediasLength is int && userMediasLength > 0) {
        MediaModel m = userMedias.last;
        if (!m.hasBeenProcessed) {
          await m.createThumbnail();
          m.setInProcessing(true);
          await m.processFile();
          m.setInProcessing(false);
          m.setHasBeenProcessed(true);
        }
      }
    });
    appInitialized = true;
  }
}
