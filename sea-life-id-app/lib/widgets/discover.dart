import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import 'package:underwater_video_tagging/models/app_model.dart';
import 'package:underwater_video_tagging/utils/ml_models.dart';
import 'package:underwater_video_tagging/widgets/media_widget.dart';
import 'package:underwater_video_tagging/app_localizations.dart';

import 'package:underwater_video_tagging/widgets/media_dialog.dart';

class Discover extends StatelessWidget {
  final AppModel appStore;

  const Discover({required this.appStore});

  Widget initializationFailedWidget(BuildContext context) {
    return Center(
      child: Container(
          width: MediaQuery.of(context).size.width * 0.60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(AppLocalizations.of(context)!.translate('discover_no_data')),
            ],
          )),
    );
  }

  void _showMultiSelect(BuildContext context) async {
    Map<String, int> stats = Map();

    for (var e in appStore.galleryMedias) {
      for (var t in e.tags) {
        stats.update(t, (val) => ++val, ifAbsent: () => 1);
      }
    }

    List tags = MlModels.tags
        .map((tag) => {
              "key": tag,
              "value": AppLocalizations.of(context)!
                  .translate('tag_' + tag.replaceAll(" ", ""))
            })
        .toList();
    tags.sort((a, b) => a["value"].compareTo(b["value"]));

    await showDialog(
      context: context,
      builder: (ctx) {
        return MultiSelectDialog(
          title: Text(AppLocalizations.of(context)!.translate("filter_photos"),
              style: TextStyle(fontSize: 18)),
          initialValue: appStore.selectedTags,
          items: tags
              .map((e) => MultiSelectItem(
                  e["key"], "${e["value"]} (${stats[e['key']] ?? 0})"))
              .toList(),
          listType: MultiSelectListType.CHIP,
          onConfirm: (values) {
            appStore.replaceTags(values);
          },
        );
      },
    );
  }

  Widget widgetDiscover(BuildContext context) {
    Widget widget = Observer(builder: (_) {
      if (!appStore.appInitialized) {
        return Padding(
            padding: EdgeInsets.all(8),
            child: Center(child: CircularProgressIndicator()));
      } else if ((appStore.appInitialized &&
          appStore.galleryMedias.length > 0)) {
        return MasonryGridView.count(
            itemCount: appStore.selectedGalleryMedias.length,
            crossAxisCount: MediaQuery.of(context).size.width < 400
                ? 1
                : (MediaQuery.of(context).size.width / 400).floor(),
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            itemBuilder: (context, index) {
              return MediaWidget(
                  mediaList: appStore.selectedGalleryMedias,
                  mediaIndex: index,
                  onTap: () async {
                    openVideoPlayer(
                        context, appStore.selectedGalleryMedias, index);
                  },
                  appStore: appStore);
            });
      } else {
        return initializationFailedWidget(context);
      }
    });
    return widget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(child: widgetDiscover(context)),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showMultiSelect(context);
            },
            heroTag: 'discoverFilterBtn',
            child: Icon(Icons.filter_list)));
  }
}
