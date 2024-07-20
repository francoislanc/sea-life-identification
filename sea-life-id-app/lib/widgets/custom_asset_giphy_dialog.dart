import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CustomAssetGiffyDialog extends StatelessWidget {
  final Image image;
  final AutoSizeText title;
  final AutoSizeText description;
  final Widget additionnalWidget;
  final bool onlyOkButton;
  final Text buttonOkText;
  final Text buttonCancelText;
  final Color? buttonOkColor;
  final Color? buttonCancelColor;
  final double buttonRadius;
  final double cornerRadius;
  final VoidCallback? onOkButtonPressed;

  CustomAssetGiffyDialog({
    required this.image,
    required this.title,
    this.onOkButtonPressed,
    required this.description,
    required this.additionnalWidget,
    this.onlyOkButton = false,
    required this.buttonOkText,
    required this.buttonCancelText,
    this.buttonOkColor,
    this.buttonCancelColor,
    this.cornerRadius = 8.0,
    this.buttonRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cornerRadius)),
        child: (MediaQuery.of(context).orientation == Orientation.portrait)
            ? AssetPortraitMode(
                cornerRadius: cornerRadius,
                image: image,
                title: title,
                description: description,
                additionnalWidget: additionnalWidget,
                onlyOkButton: onlyOkButton,
                buttonCancelColor: buttonCancelColor,
                buttonRadius: buttonRadius,
                buttonCancelText: buttonCancelText,
                buttonOkColor: buttonOkColor,
                onOkButtonPressed: onOkButtonPressed,
                buttonOkText: buttonOkText,
              )
            : AssetLandscapeMode(
                cornerRadius: cornerRadius,
                image: image,
                title: title,
                description: description,
                additionnalWidget: additionnalWidget,
                onlyOkButton: onlyOkButton,
                buttonCancelColor: buttonCancelColor,
                buttonRadius: buttonRadius,
                buttonCancelText: buttonCancelText,
                buttonOkColor: buttonOkColor,
                onOkButtonPressed: onOkButtonPressed,
                buttonOkText: buttonOkText,
              ));
  }
}

class AssetPortraitMode extends StatelessWidget {
  const AssetPortraitMode({
    required this.cornerRadius,
    required this.image,
    required this.title,
    required this.description,
    required this.additionnalWidget,
    required this.onlyOkButton,
    this.buttonCancelColor,
    required this.buttonRadius,
    this.buttonCancelText,
    this.buttonOkColor,
    this.onOkButtonPressed,
    required this.buttonOkText,
  });

  final double cornerRadius;
  final Image image;
  final AutoSizeText title;
  final AutoSizeText description;
  final Widget additionnalWidget;
  final bool onlyOkButton;
  final Color? buttonCancelColor;
  final double buttonRadius;
  final Text? buttonCancelText;
  final Color? buttonOkColor;
  final void Function()? onOkButtonPressed;
  final Text? buttonOkText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: (MediaQuery.of(context).size.height / 2) * 0.4,
                child: Card(
                  elevation: 0.0,
                  margin: EdgeInsets.all(0.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(cornerRadius),
                          topLeft: Radius.circular(cornerRadius))),
                  clipBehavior: Clip.antiAlias,
                  child: image,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: title,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: description,
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0), child: additionnalWidget),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: Row(
              mainAxisAlignment: !onlyOkButton
                  ? MainAxisAlignment.spaceEvenly
                  : MainAxisAlignment.center,
              children: <Widget>[
                !onlyOkButton
                    ? ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.lightBlue)),
                        onPressed: () => Navigator.of(context).pop(),
                        child: buttonCancelText ??
                            Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white),
                            ),
                      )
                    : Container(),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(Colors.lightBlue)),
                  onPressed: onOkButtonPressed ?? () {},
                  child: buttonOkText ??
                      Text(
                        'OK',
                        style: TextStyle(color: Colors.white),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AssetLandscapeMode extends StatelessWidget {
  const AssetLandscapeMode({
    required this.cornerRadius,
    required this.image,
    required this.title,
    required this.description,
    required this.additionnalWidget,
    required this.onlyOkButton,
    this.buttonCancelColor,
    required this.buttonRadius,
    this.buttonCancelText,
    this.buttonOkColor,
    this.onOkButtonPressed,
    required this.buttonOkText,
  });

  final double cornerRadius;
  final Image image;
  final AutoSizeText title;
  final AutoSizeText description;
  final Widget additionnalWidget;
  final bool onlyOkButton;
  final Color? buttonCancelColor;
  final double buttonRadius;
  final Text? buttonCancelText;
  final Color? buttonOkColor;
  final void Function()? onOkButtonPressed;
  final Text? buttonOkText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: (MediaQuery.of(context).size.width / 2) * 0.6,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Card(
              elevation: 0.0,
              margin: EdgeInsets.all(0.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(cornerRadius),
                      bottomLeft: Radius.circular(cornerRadius))),
              clipBehavior: Clip.antiAlias,
              child: image,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: title,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: description,
                ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: additionnalWidget),
                Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Row(
                    mainAxisAlignment: !onlyOkButton
                        ? MainAxisAlignment.spaceEvenly
                        : MainAxisAlignment.center,
                    children: <Widget>[
                      !onlyOkButton
                          ? ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: buttonCancelText ??
                                  Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.white),
                                  ),
                            )
                          : Container(),
                      ElevatedButton(
                        onPressed: onOkButtonPressed ?? () {},
                        child: buttonOkText ??
                            Text(
                              'OK',
                              style: TextStyle(color: Colors.white),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
