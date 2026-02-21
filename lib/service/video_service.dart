
import 'dart:convert';

import 'package:dio/dio.dart';

class VideoService {
  final Dio _dio = Dio();

  final String _url =
      'https://gist.githubusercontent.com/Abdelrahman-El-Kassas/a4aacad12b1b25108ed3ddb17a028de9/raw/alnabil.json';

  Future<List<dynamic>> fetchVideos() async {
    try {
      final response = await _dio.get(_url);

      if (response.data is String) {
        return json.decode(response.data);
      } else {
        return response.data;
      }
    } catch (e) {
      throw Exception('Check your Internet Connection: $e');
    }
  }
}
