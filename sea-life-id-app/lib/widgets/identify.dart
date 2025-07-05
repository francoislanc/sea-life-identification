import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:underwater_video_tagging/utils/automatic_tagging_utils.dart';
import 'package:underwater_video_tagging/widgets/media_widget.dart';
import 'package:underwater_video_tagging/widgets/media_dialog.dart';
import 'package:underwater_video_tagging/widgets/upload_media_widget.dart';
import 'package:underwater_video_tagging/models/app_model.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:underwater_video_tagging/app_localizations.dart';

class Identify extends StatelessWidget {
  final AppModel appStore;

  Identify({required this.appStore});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Observer(
          builder: (_) {
            if (!appStore.appInitialized) {
              return initializationWidget(context);
            } else if (appStore.appInitialized && !appStore.modelInitialized) {
              return initializationFailedWidget(context);
            } else {
              if (appStore.userMedias.length == 0) {
                return usageWidget(context);
              } else {
                return MasonryGridView.count(
                  padding: const EdgeInsets.only(bottom: 64.0),
                  itemCount: appStore.userMedias.length,
                  crossAxisCount: MediaQuery.of(context).size.width < 400
                      ? 1
                      : (MediaQuery.of(context).size.width / 400).floor(),
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  itemBuilder: (context, index) {
                    return MediaWidget(
                      appStore: appStore,
                      mediaList: appStore.userMedias,
                      mediaIndex: index,
                      onTap: () async {
                        openVideoPlayer(context, appStore.userMedias, index);
                      },
                    );
                  },
                );
              }
            }
          },
        ),
      ),
      floatingActionButton: Observer(
        builder: (_) {
          return Visibility(
            child: UploadMediaWidget(app: appStore),
            visible: appStore.appInitialized,
          );
        },
      ),
    );
  }

  Widget usageWidget(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.translate('home_welcome_message_1'),
            ),
            Text(
              AppLocalizations.of(context)!.translate('home_welcome_message_2'),
            ),
            SizedBox(height: 20),
            Text(AutomaticTagging.modelVersion),
          ],
        ),
      ),
    );
  }

  Widget initializationWidget(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(AppLocalizations.of(context)!.translate('app_init')),
            Padding(
              padding: EdgeInsets.all(5),
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget initializationFailedWidget(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(AppLocalizations.of(context)!.translate('app_init_failed')),
          ],
        ),
      ),
    );
  }
}
