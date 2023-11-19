import 'package:flutter/material.dart';
import 'package:underwater_video_tagging/models/app_model.dart';
import 'package:underwater_video_tagging/models/media_model.dart';
import 'package:underwater_video_tagging/widgets/detection_problem_report_widget.dart';
import 'package:underwater_video_tagging/app_localizations.dart';

class PopUpMenu extends StatelessWidget {
  final MediaModel media;
  final AppModel app;

  static const String delete = "DELETE";
  static const String detectionProblem = "DETECTION_PB";

  const PopUpMenu({required this.app, required this.media});
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: Icon(Icons.more_vert),
      onSelected: (String value) {
        if (value == PopUpMenu.delete) {
          app.removeUserMediaWithPath(media.path);
        } else if (value == PopUpMenu.detectionProblem) {
          showDialog(
              context: context,
              builder: (_) => DetectionProblemReport(media: media));
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
            value: PopUpMenu.delete,
            child: ListTile(
                leading: Icon(Icons.delete),
                title: Text(
                    AppLocalizations.of(context)!.translate('media_remove')))),
        PopupMenuItem<String>(
            value: PopUpMenu.detectionProblem,
            child: ListTile(
                leading: Icon(Icons.report_problem),
                title: Text(AppLocalizations.of(context)!
                    .translate('media_report_problem'))))
      ],
    );
  }
}
