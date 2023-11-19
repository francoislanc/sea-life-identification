import 'package:flutter/material.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:underwater_video_tagging/app_localizations.dart';

class ColoredTag extends StatelessWidget {
  const ColoredTag(
      {Key? key,
      required this.tagIndex,
      required this.tagKey,
      required this.tagValue})
      : super(key: key);

  final int tagIndex;
  final String tagKey;
  final String tagValue;

  final Map<String, Color> tagColors = const {
    'other': Colors.lightBlue,
    'coralreef': Colors.lightGreen,
    'diver': Colors.grey,
    'wreck': Colors.blueGrey,
    'submarine': Colors.blueGrey
  };
  final double _fontSize = 14;

  @override
  Widget build(BuildContext context) {
    return ItemTags(
        pressEnabled: false,
        activeColor: tagColors[tagKey] ?? Colors.blueGrey,
        title: AppLocalizations.of(context)!.translate('tag_$tagKey'),
        index: tagIndex,
        textStyle: TextStyle(
          fontSize: _fontSize,
        ));
  }
}
