import 'dart:io';
import 'package:excel/excel.dart';

class FileValidationService {
  bool validateExcel(File file) {
    try {
      final bytes = file.readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

      final sheet = excel.sheets.values.first;
      if (sheet == null) return false;

      final headers = sheet.rows.first.map((cell) => cell?.value).toList();
      return headers.contains('Vendor Name') && headers.contains('Bid Amount');
    } catch (e) {
      return false;
    }
  }

  bool validatePDF(File file) {
    // Example PDF validation: Check file extension
    return file.path.endsWith('.pdf');
  }

  bool validateFile(File file, String fileType) {
    switch (fileType) {
      case 'excel':
        return validateExcel(file);
      case 'pdf':
        return validatePDF(file);
      default:
        return false;
    }
  }
}
