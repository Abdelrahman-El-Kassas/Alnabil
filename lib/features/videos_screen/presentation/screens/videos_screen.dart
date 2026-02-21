import 'package:alnabil/service/custom_error.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:alnabil/core/constants/app_colors.dart';
import 'package:alnabil/service/video_service.dart';
import 'video_playerscreen.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  final VideoService _videoService = VideoService();
  late Future<List<dynamic>> _videosFuture;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _videosFuture = _videoService.fetchVideos();
    });
  }

  Widget _buildVideoCard(dynamic video, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(videoId: video['id']),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  YoutubePlayer.getThumbnail(videoId: video['id']),
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.maincolor,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              video['title'],
              style: const TextStyle(
                color: AppColors.blackcolor,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.black12, thickness: 1),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondcolor,
      appBar: AppBar(
        title: Text.rich(
          TextSpan(
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              letterSpacing: 2.0,
            ),
            children: [
              const TextSpan(
                text: "Mr/",
                style: TextStyle(color: AppColors.maincolor),
              ),
              const TextSpan(
                text: "NABIL  ",
                style: TextStyle(color: AppColors.blackcolor),
              ),
              const TextSpan(
                text: "El",
                style: TextStyle(color: AppColors.maincolor),
              ),
              const TextSpan(
                text: "Desokey",
                style: TextStyle(color: AppColors.blackcolor),
              ),
            ],
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(6.0),
            child: Icon(Icons.notifications),
          ),
        ],
      ),

      // إضافة RefreshIndicator للسماح بتحديث الصفحة بالسحب للأسفل
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: AppColors.maincolor,
        child: FutureBuilder<List<dynamic>>(
          future: _videosFuture,
          builder: (context, snapshot) {
            // 1. حالة التحميل
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.secondcolor),
              );
            }
            // 2. حالة وجود خطأ (مثل انقطاع الإنترنت)
            else if (snapshot.hasError) {
              String errorMsg = snapshot.error.toString().replaceAll(
                'Exception: ',
                '',
              );
              return CustomErrorWidget(
                errorMessage: errorMsg,
                onTryAgain:
                    _fetchData, // استدعاء البيانات مرة أخرى عند الضغط على الزر
              );
            }
            // 3. حالة جلب البيانات بنجاح
            else if (snapshot.hasData) {
              final List<dynamic> videos = snapshot.data!;

              // إذا كانت القائمة فارغة
              if (videos.isEmpty) {
                return ListView(
                  physics:
                      const AlwaysScrollableScrollPhysics(), // لضمان عمل السحب للتحديث حتى لو القائمة فارغة
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                    const Center(child: Text('There is no Videos now')),
                  ],
                );
              }

              // عرض الفيديوهات
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: ListView.builder(
                    physics:
                        const AlwaysScrollableScrollPhysics(), // لضمان عمل السحب للتحديث
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      return _buildVideoCard(videos[index], context);
                    },
                  ),
                ),
              );
            }

            // 4. الحالة الافتراضية إذا لم يتوفر أي مما سبق
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                const Center(child: Text('There is no Videos now')),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF25D366), // اللون الرسمي للواتساب
        onPressed: () async {
          // ضع رقم المدرس هنا مسبوقاً بكود الدولة (مثال لمصر: 20 ثم الرقم)
          final Uri whatsappUrl = Uri.parse("https://wa.me/201003882297");

          if (await canLaunchUrl(whatsappUrl)) {
            await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("لا يمكن فتح الواتساب، تأكد من تثبيت التطبيق."),
                ),
              );
            }
          }
        },
        // إذا كنت تستخدم حزمة font_awesome_flutter استخدم FaIcon(FontAwesomeIcons.whatsapp)
        // وإذا لم تكن تستخدمها، يمكنك استخدام هذه الأيقونة المؤقتة من فلاتر
        child: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 35),
      ),
    );
  }
}
