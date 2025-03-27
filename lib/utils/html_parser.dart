class HtmlParser {
  static String removeHtmlTags(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '');
  }
}
