import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mk_tv_app/route/VideoPlay.dart';
import 'package:mk_tv_app/routes.dart';
import 'route/Home.dart';
import 'route/Tv.dart';
import 'route/Library.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      initialRoute: RouteGenerator.homePage,
      onGenerateRoute: RouteGenerator.generateRoute,
      theme: ThemeData(
        useMaterial3: true,
        navigationBarTheme:
            const NavigationBarThemeData(indicatorColor: Colors.amber),
        primaryColor: Colors.blue,
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'ማኅበረ ቅዱሳን ቴቪ'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

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
      //   title: Text
      // (widget.title),
      // ),
      drawer: const Drawer(),
      body: const <Widget>[Home(), Tv(), Library()][index],
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            label: "Home",
            icon: Icon(Icons.church_outlined),
            selectedIcon: Icon(Icons.church),
          ),
          NavigationDestination(
            label: "TV",
            icon: Icon(Icons.live_tv),
            selectedIcon: Icon(Icons.live_tv_outlined),
          ),
          NavigationDestination(
            label: "Library",
            icon: Icon(Icons.video_library_outlined),
            selectedIcon: Icon(Icons.video_library_rounded),
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
