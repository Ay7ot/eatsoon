String stripHtmlTags(String htmlText) {
  // A simple regex to remove HTML tags.
  // It also replaces the tags with a space to prevent words from joining together.
  // It also handles common HTML entities.
  return htmlText
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll(RegExp(r'&nbsp;'), ' ')
      .replaceAll(RegExp(r'&amp;'), '&')
      .replaceAll(RegExp(r'&quot;'), '"')
      .replaceAll(RegExp(r'&lt;'), '<')
      .replaceAll(RegExp(r'&gt;'), '>')
      .replaceAll(
        RegExp(r'\s+'),
        ' ',
      ) // Replace multiple spaces with a single one
      .trim();
}
