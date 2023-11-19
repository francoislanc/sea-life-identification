import 'package:flutter/material.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:underwater_video_tagging/models/media_model.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:underwater_video_tagging/app_localizations.dart';
import 'package:underwater_video_tagging/widgets/colored_tag.dart';

class TagWidget extends StatelessWidget {
  final MediaModel media;

  const TagWidget({required this.media});

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      if (media.inProcessing) {
        return LinearProgressIndicator(
            value: media.processingProgress.toDouble() / 100.0);
      } else {
        if (media.tags.length == 0) {
          return Text(
              AppLocalizations.of(context)!.translate('no_categories_found'));
        } else {
          return Padding(
              padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: Tags(
                alignment: WrapAlignment.start,
                itemCount: media.uiTags.length, // required
                itemBuilder: (int index) {
                  final item = media.uiTags[index];
                  return ColoredTag(
                      tagIndex: index,
                      tagKey: item.title,
                      tagValue: AppLocalizations.of(context)!
                          .translate('tag_${item.title}'));
                },
              ));
        }
      }
    });
  }
}
