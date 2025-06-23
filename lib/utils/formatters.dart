import 'package:intl/intl.dart';

class Formatters {
  // Format currency (IDR)
  static String formatCurrency(double amount) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(amount);
  }

  // Format date (dd MMM yyyy)
  static String formatDate(DateTime date) {
    final formatDate = DateFormat('dd MMM yyyy', 'id_ID');
    return formatDate.format(date);
  }

  // Format date with time (dd MMM yyyy, HH:mm)
  static String formatDateTime(DateTime date) {
    final formatDateTime = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    return formatDateTime.format(date);
  }

  // Format date for input field (yyyy-MM-dd)
  static String formatDateInput(DateTime date) {
    final formatDateInput = DateFormat('yyyy-MM-dd');
    return formatDateInput.format(date);
  }

  // Parse date from input field
  static DateTime? parseDateInput(String dateString) {
    try {
      return DateFormat('yyyy-MM-dd').parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Format number without currency symbol
  static String formatNumber(double number) {
    final formatNumber = NumberFormat('#,##0', 'id_ID');
    return formatNumber.format(number);
  }

  // Parse currency string to double
  static double parseCurrency(String currencyString) {
    try {
      // Remove currency symbol and spaces
      String cleanString = currencyString
          .replaceAll('Rp', '')
          .replaceAll(' ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      return double.parse(cleanString);
    } catch (e) {
      return 0.0;
    }
  }

  // Get month name in Indonesian
  static String getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }

  // Get short month name in Indonesian
  static String getShortMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month - 1];
  }

  // Get day name in Indonesian
  static String getDayName(int weekday) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return days[weekday - 1];
  }

  // Format relative date (Hari ini, Kemarin, etc.)
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hari ini';
    } else if (dateOnly == yesterday) {
      return 'Kemarin';
    } else {
      return formatDate(date);
    }
  }
}
