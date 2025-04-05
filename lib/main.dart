import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project/firebase_options.dart';
import 'package:project/page/Customer/login.dart';
import 'package:project/provider/authProvider.dart';
import 'package:project/provider/theme_provider.dart';
import 'package:project/widget/theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => idAllAccountProvider()),
        ChangeNotifierProvider(create: (context) => employeeProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: MyApp(),));    
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: Provider.of<ThemeProvider>(context).themeData,
      darkTheme: darkMode,
      //home: const HomePage(),
      // home: LoginUserPage(),
      // home: MapBookMark(),
      home: LoginUserPage()
    );
  }
}
