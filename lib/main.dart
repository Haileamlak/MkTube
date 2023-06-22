import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mk_tv_app/firebase_options.dart';
import 'package:mk_tv_app/localization/app_localization.dart';
import 'package:mk_tv_app/localization/localization_delegate.dart';
import 'package:mk_tv_app/model/SettingModel.dart';
import 'package:mk_tv_app/model/libraryModel.dart';
import 'package:mk_tv_app/model/videoListModel.dart';
import 'package:mk_tv_app/route/library.dart';
import 'package:mk_tv_app/routes.dart';
import 'package:mk_tv_app/widget/MkDrawer.dart';
import 'package:provider/provider.dart';
import 'route/Home.dart';
import 'route/Tv.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<VideoListModel>(create: (_) => VideoListModel()),
    ChangeNotifierProvider<LibraryModel>(create: (_) => LibraryModel()),
    ChangeNotifierProvider<SettingModel>(create: (_) => SettingModel()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingModel>(
      builder: (context, value, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MkTube',
        initialRoute: RouteGenerator.homePage,
        onGenerateRoute: RouteGenerator.generateRoute,
        localizationsDelegates: const [
          AppLocalizationDelegate(),
// Global localization delegates provice localized
// strings and other values for the Material and
// Cupertino libraries. They support 70+ locales!
//           GlobalMaterialLocalizations.delegate,
//           GlobalCupertinoLocalizations.delegate,
//           GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale.fromSubtags(languageCode: "en"),
          Locale.fromSubtags(languageCode: "am"),
          Locale.fromSubtags(languageCode: "gez"),
        ],
        theme: value.darkMode
            ? ThemeData.dark(useMaterial3: true)
            : ThemeData(
                useMaterial3: true,
                navigationBarTheme:
                    const NavigationBarThemeData(indicatorColor: Colors.amber),
                primaryColor: Colors.blue,
                primarySwatch: Colors.blue,
                snackBarTheme:
                    const SnackBarThemeData(backgroundColor: Colors.lightBlue),
              ),
        home: AnimatedSplashScreen(
            splash: "lib/myassets/mklogo.png",
            curve: Curves.easeInOut,
            splashIconSize: 256,
            nextScreen: const MyHomePage(),
            splashTransition: SplashTransition.scaleTransition),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int index = 0;

  void changeScreen(int index) {
    setState(() {
      this.index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),

      drawer: const MkDrawer(),
      body: const <Widget>[Home(), Tv(), Library()][index],
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(
            label: context.localize("home"),
            icon: const Icon(Icons.church_outlined),
            selectedIcon: const Icon(Icons.church),
          ),
          NavigationDestination(
            label: context.localize("live"),
            icon: const Icon(Icons.live_tv),
            selectedIcon: const Icon(Icons.live_tv_outlined),
          ),
          NavigationDestination(
            label: context.localize("library"),
            icon: const Icon(Icons.video_library_outlined),
            selectedIcon: const Icon(Icons.video_library_rounded),
          )
        ],
        height: 60,
        selectedIndex: index,
        shadowColor: Colors.amber,
        surfaceTintColor: Colors.blue,
        onDestinationSelected: changeScreen,
      ),
    );
  }
}
