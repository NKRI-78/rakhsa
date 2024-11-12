import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:rakhsa/features/pages/event/persentation/pages/list.dart';
import 'package:rakhsa/features/pages/news/persentation/pages/list.dart';

import 'package:rakhsa/injection.dart' as di;

import 'package:rakhsa/common/helpers/storage.dart';

import 'package:rakhsa/features/pages/dashboard/presentation/pages/dashboard.dart';
import 'package:rakhsa/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageHelper.init();

  di.init();

  runApp(MultiProvider(providers: providers, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home',
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const NewsListPage(),
    );
  }
}
