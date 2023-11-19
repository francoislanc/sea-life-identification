// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_model.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$MediaModel on MediaModelBase, Store {
  Computed<List<ItemTags>>? _$uiTagsComputed;

  @override
  List<ItemTags> get uiTags =>
      (_$uiTagsComputed ??= Computed<List<ItemTags>>(() => super.uiTags,
              name: 'MediaModelBase.uiTags'))
          .value;

  late final _$thumbnailAtom =
      Atom(name: 'MediaModelBase.thumbnail', context: context);

  @override
  Uint8List? get thumbnail {
    _$thumbnailAtom.reportRead();
    return super.thumbnail;
  }

  @override
  set thumbnail(Uint8List? value) {
    _$thumbnailAtom.reportWrite(value, super.thumbnail, () {
      super.thumbnail = value;
    });
  }

  late final _$tagsAtom = Atom(name: 'MediaModelBase.tags', context: context);

  @override
  ObservableList<String> get tags {
    _$tagsAtom.reportRead();
    return super.tags;
  }

  @override
  set tags(ObservableList<String> value) {
    _$tagsAtom.reportWrite(value, super.tags, () {
      super.tags = value;
    });
  }

  late final _$hasBeenProcessedAtom =
      Atom(name: 'MediaModelBase.hasBeenProcessed', context: context);

  @override
  bool get hasBeenProcessed {
    _$hasBeenProcessedAtom.reportRead();
    return super.hasBeenProcessed;
  }

  @override
  set hasBeenProcessed(bool value) {
    _$hasBeenProcessedAtom.reportWrite(value, super.hasBeenProcessed, () {
      super.hasBeenProcessed = value;
    });
  }

  late final _$inProcessingAtom =
      Atom(name: 'MediaModelBase.inProcessing', context: context);

  @override
  bool get inProcessing {
    _$inProcessingAtom.reportRead();
    return super.inProcessing;
  }

  @override
  set inProcessing(bool value) {
    _$inProcessingAtom.reportWrite(value, super.inProcessing, () {
      super.inProcessing = value;
    });
  }

  late final _$processingProgressAtom =
      Atom(name: 'MediaModelBase.processingProgress', context: context);

  @override
  int get processingProgress {
    _$processingProgressAtom.reportRead();
    return super.processingProgress;
  }

  @override
  set processingProgress(int value) {
    _$processingProgressAtom.reportWrite(value, super.processingProgress, () {
      super.processingProgress = value;
    });
  }

  late final _$extractingImagesAtom =
      Atom(name: 'MediaModelBase.extractingImages', context: context);

  @override
  bool get extractingImages {
    _$extractingImagesAtom.reportRead();
    return super.extractingImages;
  }

  @override
  set extractingImages(bool value) {
    _$extractingImagesAtom.reportWrite(value, super.extractingImages, () {
      super.extractingImages = value;
    });
  }

  late final _$createThumbnailAsyncAction =
      AsyncAction('MediaModelBase.createThumbnail', context: context);

  @override
  Future<void> createThumbnail() {
    return _$createThumbnailAsyncAction.run(() => super.createThumbnail());
  }

  late final _$MediaModelBaseActionController =
      ActionController(name: 'MediaModelBase', context: context);

  @override
  void addTag(String tag) {
    final _$actionInfo = _$MediaModelBaseActionController.startAction(
        name: 'MediaModelBase.addTag');
    try {
      return super.addTag(tag);
    } finally {
      _$MediaModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeTagAt(int index) {
    final _$actionInfo = _$MediaModelBaseActionController.startAction(
        name: 'MediaModelBase.removeTagAt');
    try {
      return super.removeTagAt(index);
    } finally {
      _$MediaModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setHasBeenProcessed(bool v) {
    final _$actionInfo = _$MediaModelBaseActionController.startAction(
        name: 'MediaModelBase.setHasBeenProcessed');
    try {
      return super.setHasBeenProcessed(v);
    } finally {
      _$MediaModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setInProcessing(bool v) {
    final _$actionInfo = _$MediaModelBaseActionController.startAction(
        name: 'MediaModelBase.setInProcessing');
    try {
      return super.setInProcessing(v);
    } finally {
      _$MediaModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setProcessingProgress(int v) {
    final _$actionInfo = _$MediaModelBaseActionController.startAction(
        name: 'MediaModelBase.setProcessingProgress');
    try {
      return super.setProcessingProgress(v);
    } finally {
      _$MediaModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setExtractingImages(bool v) {
    final _$actionInfo = _$MediaModelBaseActionController.startAction(
        name: 'MediaModelBase.setExtractingImages');
    try {
      return super.setExtractingImages(v);
    } finally {
      _$MediaModelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
thumbnail: ${thumbnail},
tags: ${tags},
hasBeenProcessed: ${hasBeenProcessed},
inProcessing: ${inProcessing},
processingProgress: ${processingProgress},
extractingImages: ${extractingImages},
uiTags: ${uiTags}
    ''';
  }
}
