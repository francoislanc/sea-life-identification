// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_model.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AppModel on AppModelBase, Store {
  Computed<ObservableList<MediaModel>>? _$selectedGalleryMediasComputed;

  @override
  ObservableList<MediaModel> get selectedGalleryMedias =>
      (_$selectedGalleryMediasComputed ??= Computed<ObservableList<MediaModel>>(
              () => super.selectedGalleryMedias,
              name: 'AppModelBase.selectedGalleryMedias'))
          .value;

  late final _$userMediasAtom =
      Atom(name: 'AppModelBase.userMedias', context: context);

  @override
  ObservableList<MediaModel> get userMedias {
    _$userMediasAtom.reportRead();
    return super.userMedias;
  }

  @override
  set userMedias(ObservableList<MediaModel> value) {
    _$userMediasAtom.reportWrite(value, super.userMedias, () {
      super.userMedias = value;
    });
  }

  late final _$galleryMediasAtom =
      Atom(name: 'AppModelBase.galleryMedias', context: context);

  @override
  ObservableList<MediaModel> get galleryMedias {
    _$galleryMediasAtom.reportRead();
    return super.galleryMedias;
  }

  @override
  set galleryMedias(ObservableList<MediaModel> value) {
    _$galleryMediasAtom.reportWrite(value, super.galleryMedias, () {
      super.galleryMedias = value;
    });
  }

  late final _$selectedTagsAtom =
      Atom(name: 'AppModelBase.selectedTags', context: context);

  @override
  ObservableList<String> get selectedTags {
    _$selectedTagsAtom.reportRead();
    return super.selectedTags;
  }

  @override
  set selectedTags(ObservableList<String> value) {
    _$selectedTagsAtom.reportWrite(value, super.selectedTags, () {
      super.selectedTags = value;
    });
  }

  late final _$galleryElementsNumberAtom =
      Atom(name: 'AppModelBase.galleryElementsNumber', context: context);

  @override
  int get galleryElementsNumber {
    _$galleryElementsNumberAtom.reportRead();
    return super.galleryElementsNumber;
  }

  @override
  set galleryElementsNumber(int value) {
    _$galleryElementsNumberAtom.reportWrite(value, super.galleryElementsNumber,
        () {
      super.galleryElementsNumber = value;
    });
  }

  late final _$galleryInitializedAtom =
      Atom(name: 'AppModelBase.galleryInitialized', context: context);

  @override
  bool get galleryInitialized {
    _$galleryInitializedAtom.reportRead();
    return super.galleryInitialized;
  }

  @override
  set galleryInitialized(bool value) {
    _$galleryInitializedAtom.reportWrite(value, super.galleryInitialized, () {
      super.galleryInitialized = value;
    });
  }

  late final _$appInitializedAtom =
      Atom(name: 'AppModelBase.appInitialized', context: context);

  @override
  bool get appInitialized {
    _$appInitializedAtom.reportRead();
    return super.appInitialized;
  }

  @override
  set appInitialized(bool value) {
    _$appInitializedAtom.reportWrite(value, super.appInitialized, () {
      super.appInitialized = value;
    });
  }

  late final _$modelInitializedAtom =
      Atom(name: 'AppModelBase.modelInitialized', context: context);

  @override
  bool get modelInitialized {
    _$modelInitializedAtom.reportRead();
    return super.modelInitialized;
  }

  @override
  set modelInitialized(bool value) {
    _$modelInitializedAtom.reportWrite(value, super.modelInitialized, () {
      super.modelInitialized = value;
    });
  }

  late final _$initializeAsyncAction =
      AsyncAction('AppModelBase.initialize', context: context);

  @override
  Future<void> initialize() {
    return _$initializeAsyncAction.run(() => super.initialize());
  }

  late final _$AppModelBaseActionController =
      ActionController(name: 'AppModelBase', context: context);

  @override
  void showMoreGalleryElements() {
    final _$actionInfo = _$AppModelBaseActionController.startAction(
        name: 'AppModelBase.showMoreGalleryElements');
    try {
      return super.showMoreGalleryElements();
    } finally {
      _$AppModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addUserMedia(MediaModel item) {
    final _$actionInfo = _$AppModelBaseActionController.startAction(
        name: 'AppModelBase.addUserMedia');
    try {
      return super.addUserMedia(item);
    } finally {
      _$AppModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addGalleryMedia(MediaModel item) {
    final _$actionInfo = _$AppModelBaseActionController.startAction(
        name: 'AppModelBase.addGalleryMedia');
    try {
      return super.addGalleryMedia(item);
    } finally {
      _$AppModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeUserMediaAt(int index) {
    final _$actionInfo = _$AppModelBaseActionController.startAction(
        name: 'AppModelBase.removeUserMediaAt');
    try {
      return super.removeUserMediaAt(index);
    } finally {
      _$AppModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeUserMediaWithPath(String path) {
    final _$actionInfo = _$AppModelBaseActionController.startAction(
        name: 'AppModelBase.removeUserMediaWithPath');
    try {
      return super.removeUserMediaWithPath(path);
    } finally {
      _$AppModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void replaceTags(List<Object?> tags) {
    final _$actionInfo = _$AppModelBaseActionController.startAction(
        name: 'AppModelBase.replaceTags');
    try {
      return super.replaceTags(tags);
    } finally {
      _$AppModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
userMedias: ${userMedias},
galleryMedias: ${galleryMedias},
selectedTags: ${selectedTags},
galleryElementsNumber: ${galleryElementsNumber},
galleryInitialized: ${galleryInitialized},
appInitialized: ${appInitialized},
modelInitialized: ${modelInitialized},
selectedGalleryMedias: ${selectedGalleryMedias}
    ''';
  }
}
