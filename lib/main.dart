import 'package:alnabil/features/videos_screen/presentation/screens/videos_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // أضف هذا السطر

Future<void> main() async {
  // السطر ده مهم جداً قبل أي await في الـ main
  WidgetsFlutterBinding.ensureInitialized(); 

  // تحميل ملف المتغيرات
  await dotenv.load(fileName: ".env");

  // تهيئة Supabase باستخدام المتغيرات المخفية
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const VideosScreen(),

      //body:
    );
  }
}
