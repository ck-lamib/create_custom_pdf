extension StringExtension on String {
  String getFileExtension() {
    return split(".").last;
  }
}
