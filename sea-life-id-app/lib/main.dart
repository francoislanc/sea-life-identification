import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:underwater_video_tagging/models/app_model.dart';
import 'package:underwater_video_tagging/widgets/app_bar.dart';
import 'package:underwater_video_tagging/widgets/discover.dart';
import 'package:underwater_video_tagging/widgets/identify.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:underwater_video_tagging/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    UnderwaterVideoTaggingApp(),
  );
}

class UnderwaterVideoTaggingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Colors.lightBlue,
          primaryTextTheme:
              TextTheme(titleLarge: TextStyle(color: Colors.white))),
      home: MainPage(),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [const Locale('en', 'US'), const Locale('fr', 'FR')],
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the current device locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode &&
              supportedLocale.countryCode == locale?.countryCode) {
            return supportedLocale;
          }
        }
        // If the locale of the device is not supported, use the first one
        // from the list (English, in this case).
        return supportedLocales.first;
      },
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage() : super();

  final AppModel appStore = AppModel();

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  initState() {
    super.initState();
    init();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> init() async {
    await widget.appStore.initialize();
  }

  void _handleTabs(int tabIndex) {
    _tabController.animateTo(tabIndex,
        duration: const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            backgroundColor: Colors.lightBlue,
            elevation: 0,
            titleSpacing: 0,
            flexibleSpace: MyAppBar(
              tabController: _tabController,
              tabHandler: _handleTabs,
            )),
        body: Container(
          child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: [
              Identify(appStore: widget.appStore),
              Discover(appStore: widget.appStore),
            ],
          ),
        ));
  }
}
