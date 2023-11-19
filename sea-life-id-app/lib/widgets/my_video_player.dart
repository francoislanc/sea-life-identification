import 'dart:async';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:underwater_video_tagging/models/media_model.dart';
import 'package:video_player/video_player.dart';

class MyVideoPlayer extends StatefulWidget {
  final MediaModel media;

  const MyVideoPlayer({required this.media});

  @override
  _MyVideoPlayerState createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  VideoPlayerController? _controller;
  late ChewieController _chewieController;
  final BaseCacheManager _cacheManager = DefaultCacheManager();

  @override
  Widget build(BuildContext context) {
    if (_controller != null && _controller!.value.isInitialized) {
      return Container(
          color: Colors.transparent,
          child: Chewie(controller: _chewieController));
    } else {
      return Container(
          height: 300, child: Center(child: CircularProgressIndicator()));
    }
  }

  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  void asyncInit() async {
    try {
      if (widget.media.isLocal) {
        _controller = VideoPlayerController.file(File(widget.media.path));
      } else {
        final fileInfo =
            await _cacheManager.getFileFromCache(widget.media.path);
        if (fileInfo == null) {
          unawaited(_cacheManager.downloadFile(widget.media.path));
          _controller =
              VideoPlayerController.networkUrl(Uri(path: widget.media.path));
        } else {
          _controller = VideoPlayerController.file(fileInfo.file);
        }
      }

      await _controller!.initialize();
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _controller!,
          aspectRatio: _controller!.value.aspectRatio,
          autoPlay: true,
          looping: false,
        );
      });
    } catch (e) {
      print(
          'Unable to create videpo player, Caught Exception: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _chewieController.dispose();
    super.dispose();
  }
}
