import 'package:intl/intl.dart';

class DateFormater {
  static String formatDate(String? inputDate) {
    // Check for null or empty input
    if (inputDate == null || inputDate.isEmpty) {
      return 'Invalid date: Input is null or empty';
    }

    try {
      // Define possible input formats
      DateTime dateTime;

      // Try parsing with DateTime.parse for ISO 8601 or similar formats
      try {
        dateTime = DateTime.parse(inputDate);
      } catch (e) {
        // If DateTime.parse fails, try parsing with DateFormat
        // Add more formats as needed based on your input
        final possibleFormats = [
          DateFormat('dd/MM/yyyy'),
          DateFormat('dd-MM-yyyy'),
          DateFormat('yyyy-MM-dd'),
          DateFormat('yyyy/MM/dd'),
        ];

        dateTime = DateTime.now(); // Default value to avoid unassigned error
        bool parsed = false;

        for (var format in possibleFormats) {
          try {
            dateTime = format.parseStrict(inputDate);
            parsed = true;
            break;
          } catch (e) {
            // Continue to try next format
          }
        }

        if (!parsed) {
          return 'Invalid date format: $inputDate';
        }
      }

      // Format the parsed DateTime to desired output format
      DateFormat formatter = DateFormat('dd-MM-yyyy');
      return formatter.format(dateTime);
    } catch (e) {
      return 'Error formatting date: $e';
    }
  }
}
