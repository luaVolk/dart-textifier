library textifier;

import 'dart:html';
import 'dart:js';
import 'dart:math';

import 'src/utils.dart';

class Textifier {
  // WARNING: maxWidth and maxHeight are measured in characters, unless specified
  dynamic maxWidth;
  dynamic maxHeight;

  String characters;
  String background;
  bool ordered;
  int color;

  Map<String, num> font;

  CanvasElement canvas = document.createElement('canvas');
  CanvasRenderingContext2D ctx;

  // Some "constants"
  static const int COLORED = 0;
  static const int GRAYSCALE = 1;
  static const int MONOCHROME = 2;

  static const int HTML = 0;
  static const int CANVAS = 1;
  static const int CONSOLE = 2;

  Textifier({
    this.maxWidth: double.infinity, 
    this.maxHeight: double.infinity,
    this.characters: '01',
    this.background: '#00000000', // Tranparent
    this.ordered: false, // Random
    this.color: COLORED // Colored
  }) {

    ctx = canvas.getContext('2d');

    this.font = getLetterDimensions();

    NodeValidatorBuilder BUILDER = new NodeValidatorBuilder.common();
    BUILDER.allowInlineStyles();
    VALIDATOR = BUILDER;

  }

  Future<Map<String, dynamic>> getPixels(String url) {

    ImageElement img = new ImageElement(src: url);

    return img.onLoad.first.then((Event e) {
      List<int> dimensions = scaleDimensions(img.width, img.height, this.maxWidth, this.maxHeight, this.font);

      int width = dimensions[0];
      int height = dimensions[1];

      this.canvas.width = width;
      this.canvas.height = height;

      this.ctx.fillStyle = this.background;
      this.ctx.fillRect(0, 0, width, height);
      this.ctx.drawImageScaled(img, 0, 0, width, height);

      ImageData imageData = this.ctx.getImageData(0, 0, width, height);

      List<Map<String, num>> pixels = [];

      for (int i = 0; i < imageData.data.length; i += 4) {

        pixels.add({
          'r': imageData.data[i],
          'g': imageData.data[i + 1],
          'b': imageData.data[i + 2],
          'a': imageData.data[i + 3] / 255
        });

      }

      return {
        'pixels': pixels,
        'width': width,
        'height': height
      };

    });
  }

  Future<List<String>> createCharacters(int type, String url) {
    return getPixels(url).then((data) {

      List<String> characters = [];
      String log = '';

      if (type == CANVAS) {

        this.canvas.width = (data['width'] * this.font['width']).round();
        this.canvas.height = (data['height'] * this.font['height']).round();

        this.ctx.font = 'monospace';
        this.ctx.fillStyle = '#00000000';
        this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
      }

      for (int i = 0; i < data['pixels'].length; i++) {

        num r = data['pixels'][i]['r'],
            g = data['pixels'][i]['g'],
            b = data['pixels'][i]['b'],
            a = data['pixels'][i]['a'];

        int avg;

        if (this.color != COLORED) {
          avg = toGrayscale(r, g, b);

          if (this.color == MONOCHROME) {
            avg = avg > 127 ? 255 : 0;
            a = a > 0.5 ? 1 : 0;
          }

          r = g = b = avg;
        }

        String character;

        if (a == 0) {
          character = ' ';
        } else if (this.ordered) {
          character = this.characters[i % this.characters.length];
        } else {
          character = this.characters[(new Random().nextDouble() * this.characters.length).floor()];
        }

        // TODO: DRY this
        if (type == HTML) {

          if (character == ' ') {
            characters.add(character);
          } else {
            characters.add('<span style="color: rgba($r, $g, $b, $a)">$character</span>');
          }

          if ((i + 1) % data['width'] == 0) {
            characters.add('\n');
          }

        } else if (type == CANVAS) {

          if (character != ' ') {
            this.ctx.fillStyle = 'rgba($r, $g, $b, $a)';
            this.ctx.fillText(character, (i + 1) % data['width'] * this.font['width'], (i / data['width']).ceil() * this.font['height']);
          }

        } else {

          if (character == ' ') {
            log += ' ';
          } else {
            log += '%c' + character;
            characters.add('color: rgba($r, $g, $b, $a)');
          }

          if ((i + 1) % data['width'] == 0) {
            log += '\n';
          }

        }
      }

      if (type == CONSOLE) { //If console
        characters.insert(0, '\n' + log);
      }

      return characters;
    });
  }

  Future<Node> write(String url, Element el, [bool append = false]) {
    return createCharacters(0, url).then((html) {

      if (!append) {
        el.setInnerHtml('');
      }

      Element finale = document.createElement('pre');

      finale.setInnerHtml(html.join(''), validator: VALIDATOR);

      return el.append(finale);
    })
    .catchError((error) {
      print(error);
    });
  }

  Future<Node> draw(String url, Element el, [bool append = false]) {
    return this.createCharacters(1, url).then((html) {

      if (!append) {
        el.setInnerHtml('');
      }

      return el.append(this.canvas);
    })
    .catchError((error) {
      print(error);
    });
  }

  log(String url) {
    return createCharacters(2, url).then((html) {
      context['console'].callMethod('log', html);
    })
    .catchError((error) {
      print(error);
    });
  }
}