import 'dart:html';

NodeValidator VALIDATOR;

// Helper functions
int toGrayscale(r, g, b) => (0.21 * r + 0.72 * g + 0.07 * b).round();

Map<String, num> getLetterDimensions() {
  Element pre = document.createElement('pre');
  pre.style.display = 'inline';
  pre.text = ' ';
  document.body.append(pre);

  Rectangle rect = pre.getBoundingClientRect();
  num width = rect.width;
  num height = rect.height;

  pre.remove();

  return {
    'ratio': height / width,
    'width': width,
    'height': height
  };
}

List<num> measureUnits(dynamic number, String dir, Map<String, num> font) {
  if (!(number is num) || number <= 0) {
    Element div = document.createElement('div');
    div.style.position = 'absolute';
    div.style.setProperty(dir, number);

    document.body.append(div);

    Rectangle rect = div.getBoundingClientRect();

    num width = (rect.width / font['width']).floor();
    num height = (rect.height / font['height']).floor();

    div.remove();

    return [width > 0 ? width : double.infinity,
            height > 0 ? height : double.infinity];
  }

  return [number, number];
}

List<int> scaleDimensions(int width, int height, dynamic maxWidth, dynamic maxHeight, Map<String, num> font) {

  maxWidth = measureUnits(maxWidth, 'width', font)[0];
  maxHeight = measureUnits(maxHeight, 'height', font)[1];

  int newWidth = (font['ratio'] * width).floor();
  int newHeight = height;

  if (newWidth > maxWidth) {
    newHeight = (newHeight * maxWidth / newWidth).ceil();
    newWidth = maxWidth;
  }

  if (newHeight > maxHeight) {
    newWidth = (newWidth * maxHeight / newHeight).ceil();
    newHeight = maxHeight;
  }

  return [newWidth, newHeight];
}