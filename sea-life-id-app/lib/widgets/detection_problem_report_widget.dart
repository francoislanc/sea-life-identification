import 'package:flutter/material.dart';
import 'package:underwater_video_tagging/models/media_model.dart';
import 'package:underwater_video_tagging/utils/firebase_storage_utils.dart';
import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:underwater_video_tagging/app_localizations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:underwater_video_tagging/widgets/custom_asset_giphy_dialog.dart';

class DetectionProblemReport extends StatefulWidget {
  final MediaModel media;

  const DetectionProblemReport({required this.media});

  @override
  _DetectionProblemReportState createState() => _DetectionProblemReportState();
}

class _DetectionProblemReportState extends State<DetectionProblemReport> {
  static const String storageFolderName = "reported_media";
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CustomAssetGiffyDialog(
      image: Image.asset(
        'assets/happy_fishes.gif',
        fit: BoxFit.cover,
      ),
      title: AutoSizeText(
        AppLocalizations.of(context)!
            .translate('detection_problem_report_title'),
        style: TextStyle(fontSize: 20),
        maxLines: 1,
      ),
      description: AutoSizeText(
        AppLocalizations.of(context)!
            .translate('detection_problem_report_details'),
        textAlign: TextAlign.center,
        maxLines: 3,
      ),
      additionnalWidget: TextField(
        decoration: new InputDecoration(
            prefixIcon: Icon(Icons.feedback),
            hintText: AppLocalizations.of(context)!
                .translate('detection_problem_report_comment')),
        maxLength: 280,
        maxLines: 2,
        controller: myController,
      ),
      buttonCancelText: Text(
        AppLocalizations.of(context)!
            .translate('detection_problem_report_cancel'),
        style: TextStyle(color: Colors.white),
      ),
      buttonOkText: Text(
        AppLocalizations.of(context)!.translate('detection_problem_report_ok'),
        style: TextStyle(color: Colors.white),
      ),
      onOkButtonPressed: () async {
        await FirebaseStorageUtils.uploadMedia(
            storageFolderName, '0', File(widget.media.path), myController.text);
        Navigator.of(context).pop();

        Flushbar(
          message: AppLocalizations.of(context)!
              .translate('detection_problem_report_thankyou'),
          duration: Duration(seconds: 3),
        )..show(context);
      },
    );
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }
}
