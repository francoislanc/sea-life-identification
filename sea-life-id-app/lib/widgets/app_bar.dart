import 'package:flutter/material.dart';
import 'package:underwater_video_tagging/app_localizations.dart';
import 'package:underwater_video_tagging/widgets/border_tab_indicator.dart';
import 'package:underwater_video_tagging/widgets/image_placeholder.dart';

const appPaddingSmall = 24.0;
const isDesktop = false;
const cranePrimaryWhite = Color(0xFFFFFFFF);

class MyAppBar extends StatefulWidget {
  final Function(int) tabHandler;
  final TabController tabController;

  const MyAppBar({required this.tabHandler, required this.tabController});

  @override
  _MyAppBarState createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: appPaddingSmall,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const ExcludeSemantics(
              child: FadeInImagePlaceholder(
                image: ExactAssetImage('assets/white_logo.png'),
                placeholder: SizedBox(
                  width: 40,
                  height: 60,
                ),
                width: 40,
                height: 60,
              ),
            ),
            Spacer(),
            Container(
              width: 250,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 24),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                  ),
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    indicator: BorderTabIndicator(
                      indicatorHeight: 32,
                      textScaleFactor: 1,
                    ),
                    controller: widget.tabController,
                    labelPadding: isDesktop
                        ? const EdgeInsets.symmetric(horizontal: 32)
                        : EdgeInsets.zero,
                    isScrollable: isDesktop, // left-align tabs on desktop
                    labelStyle: Theme.of(context).textTheme.labelLarge,
                    labelColor: cranePrimaryWhite,
                    unselectedLabelColor: cranePrimaryWhite.withOpacity(.6),
                    onTap: (index) => widget.tabController.animateTo(
                      index,
                      duration: const Duration(milliseconds: 300),
                    ),
                    tabs: [
                      Container(
                          width: 100.0,
                          child: Tab(
                              text: AppLocalizations.of(context)!
                                  .translate('identify_tab'))),
                      Container(
                          width: 100.0,
                          child: Tab(
                              text: AppLocalizations.of(context)!
                                  .translate('discover_tab'))),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
