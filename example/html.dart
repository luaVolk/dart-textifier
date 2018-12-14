import 'dart:html';
import 'package:textifier/textifier.dart';

main() {
  Textifier textifier = new Textifier();
  Element target = document.getElementById('target');

  document.querySelector('form').addEventListener('submit', (Event e) {
    e.preventDefault();

    target.text = 'Processing...';

    dynamic maxHeight = (document.getElementById('maxHeight') as TextInputElement).value ?? textifier.maxHeight;
    dynamic maxWidth = (document.getElementById('maxWidth') as TextInputElement).value ?? textifier.maxWidth;
    String charVal = (document.getElementById('characters') as TextInputElement).value ?? textifier.characters;
    String bgVal = (document.getElementById('background') as TextInputElement).value ?? textifier.background;

    if (maxHeight is String) {
      textifier.maxHeight = int.parse(maxHeight, onError: (source) => -1) < 0 ? maxHeight : int.parse(maxHeight);
    }

    if (maxWidth is String) {
      textifier.maxWidth = int.parse(maxWidth, onError: (source) => -1) < 0 ? maxWidth : int.parse(maxWidth);
    }

    textifier.color = int.parse((document.getElementById('color') as SelectElement).value.toString(), onError: (source) => 0);

    textifier.characters = charVal != '' ? charVal : textifier.characters; // Dont change if empty
    textifier.background = bgVal != '' ? bgVal : textifier.background; // Dont change if empty

    textifier.ordered = (document.getElementById('ordered') as CheckboxInputElement).checked ? true : false;

    textifier.write((document.getElementById('piggies') as ImageElement).src, target);
  });
}

