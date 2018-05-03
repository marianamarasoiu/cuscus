@JS()
library formula_parser.js;

import 'package:js/js.dart';

@JS("parseFormula")
external String parseFormula(String formula);
