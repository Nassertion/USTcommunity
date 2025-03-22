import 'package:intl/intl.dart';

String formatPostDate(String dateString) {
  DateTime postDate = DateTime.parse(dateString);
  DateTime now = DateTime.now();

  if (now.year != postDate.year) {
    return "${postDate.year}";
  }
  String formattedDate =
      "${postDate.day} ${DateFormat('MMMM', 'ar').format(postDate)}";
  return formattedDate;
}
