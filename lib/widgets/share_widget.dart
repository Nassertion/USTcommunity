import 'package:flutter/services.dart';
import 'package:graduation_project/constant/ConstantLinks.dart';
import 'package:share_plus/share_plus.dart';

Future<void> sharePost(int postId) async {
  try {
    final String postUrl = "${linkPost}$postId";

    await Share.share(postUrl);

    print(" تم مشاركة الرابط: $postUrl");
  } catch (e) {
    print(" خطأ أثناء مشاركة الرابط: $e");
  }
}

Future<void> copyToClipboard(String text) async {
  try {
    await Clipboard.setData(ClipboardData(text: text));
    print(" تم نسخ الرابط إلى الحافظة: $text");
  } catch (e) {
    print(" خطأ أثناء نسخ الرابط: $e");
  }
}
