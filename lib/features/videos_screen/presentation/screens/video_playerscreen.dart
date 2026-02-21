import 'dart:async';
import 'package:alnabil/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;

  const VideoPlayerScreen({super.key, required this.videoId});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isMuted = false;

  int _seekSeconds = 0;
  PlayerState _prevState = PlayerState.unknown;
  Timer? _seekTimer;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        hideThumbnail: true,
        enableCaption: false,
      ),
    )..addListener(_enforceAudioState); // 👈 ربط المراقب الدائم
  }

  // 👈 المراقب الدائم: طوال تشغيل الفيديو، لو اكتشف أن الصوت انقطع بالغلط، يرجعه فوراً
 // المراقب الذكي: يتدخل فقط عندما يعود الفيديو للتشغيل بعد التحميل (Buffering)
  void _enforceAudioState() {
    final currentState = _controller.value.playerState;

    if (currentState == PlayerState.playing && _prevState == PlayerState.buffering && !_isMuted) {
      _controller.unMute();
      _controller.setVolume(100);
    }

    // تحديث الحالة السابقة لتتبع التغييرات
    _prevState = currentState;
  }

  @override
  void dispose() {
    _seekTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _handleSeek(int seconds) {
    _seekSeconds += seconds;
    _seekTimer?.cancel();

    _seekTimer = Timer(const Duration(milliseconds: 500), () {
      final currentPosition = _controller.value.position;
      final targetPosition = currentPosition + Duration(seconds: _seekSeconds);

      _controller.seekTo(targetPosition);

      // 👈 إجبار الفيديو على استكمال التشغيل بقوة لعدم تجميد محرك الصوت
      _controller.play();

      _seekSeconds = 0;

      if (!_isMuted) {
        _controller.unMute();
        _controller.setVolume(100);

        // 👈 زيادة وقت التأكيد لثانية كاملة ونصف لضمان انتهاء التحميل (Buffering)
        Future.delayed(const Duration(milliseconds: 1100), () {
          _controller.unMute();
          _controller.setVolume(100);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: false,
        progressIndicatorColor: AppColors.maincolor,
        bufferIndicator: const SizedBox.shrink(),

        onReady: () {
          _controller.unMute();
          _controller.setVolume(100);
        },

        bottomActions: [
          const CurrentPosition(),
          const ProgressBar(isExpanded: true),
          IconButton(
            icon: Icon(
              _isMuted ? Icons.volume_off : Icons.volume_up,
              color: AppColors.secondcolor,
            ),
            onPressed: () {
              setState(() {
                _isMuted = !_isMuted;
              });
              if (_isMuted) {
                _controller.mute();
              } else {
                _controller.unMute();
                _controller.setVolume(100);
              }
            },
          ),
          const PlaybackSpeedButton(),
          const FullScreenButton(),
        ],
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: AppColors.blackcolor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.secondcolor),
          ),
          body: Center(
            child: Stack(
              children: [
                player,
                Positioned.fill(
                  bottom: 60,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onDoubleTap: () => _handleSeek(-10),
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: IgnorePointer(
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onDoubleTap: () => _handleSeek(10),
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
