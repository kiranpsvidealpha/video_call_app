import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TimeUtility {
  static DateTime parseTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return dateTime;
  }

  static String formatTimeAgo(Timestamp timestamp) {
    DateTime now = DateTime.now();
    DateTime dateTime = parseTimestamp(timestamp);
    Duration difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    }
  }
}
