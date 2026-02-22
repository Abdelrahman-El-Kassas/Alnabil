import 'package:supabase_flutter/supabase_flutter.dart';

class VideoService {
  // تعريف عميل Supabase
  final _supabase = Supabase.instance.client;

  Future<List<dynamic>> fetchVideos() async {
    try {

      final data = await _supabase.from('videos').select();

      return data;
    } catch (e) {
    
      throw Exception('Check your Internet Connection: $e');
    }
  }
}
