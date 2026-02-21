import 'package:flutter/material.dart';

class CustomErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onTryAgain;

  const CustomErrorWidget({
    super.key,
    required this.errorMessage,
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // لكي لا يأخذ مساحة أكبر من حجمه
          children: [
            const Icon(
              Icons.wifi_off_rounded, // أيقونة معبرة عن انقطاع النت
              size: 80, 
              color: Colors.grey, // لون محايد يعمل مع أي تطبيق
            ),
            const SizedBox(height: 16), 
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onTryAgain,
              icon: const Icon(Icons.refresh),
              label: const Text(
                "Try Again",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}