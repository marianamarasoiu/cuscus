import 'dart:math' as math;

import 'spreadsheet.dart';

LiteralBoolValue i_eq(LiteralValue x, LiteralValue y) => new LiteralBoolValue(x.value == y.value);
LiteralBoolValue i_neq(LiteralValue x, LiteralValue y) => new LiteralBoolValue(x.value != y.value);
LiteralBoolValue i_lt(LiteralValue x, LiteralValue y) {
  if (x is LiteralDoubleValue && y is LiteralDoubleValue) {
    return new LiteralBoolValue(x.value < y.value);
  }
  if (x is LiteralBoolValue) {
    return new LiteralBoolValue(!x.value);
  }
  if (y is LiteralBoolValue) {
    return new LiteralBoolValue(y.value);
  }
  if (x is LiteralStringValue || y is LiteralStringValue) {
    return new LiteralBoolValue(x.value.toString().compareTo(y.value.toString()) < 0);
  }
  throw "Value type unrecognized, got ${x.runtimeType} and ${y.runtimeType}";
}

LiteralBoolValue i_gt(LiteralValue x, LiteralValue y) {
  if (x is LiteralDoubleValue && y is LiteralDoubleValue) {
    return new LiteralBoolValue(x.value > y.value);
  }
  if (x is LiteralBoolValue) {
    return new LiteralBoolValue(x.value);
  }
  if (y is LiteralBoolValue) {
    return new LiteralBoolValue(!y.value);
  }
  if (x is LiteralStringValue || y is LiteralStringValue) {
    return new LiteralBoolValue(x.value.toString().compareTo(y.value.toString()) > 0);
  }
  throw "Value type unrecognized, got ${x.runtimeType} and ${y.runtimeType}";
}

LiteralBoolValue i_le(LiteralValue x, LiteralValue y) {
  if (x is LiteralDoubleValue && y is LiteralDoubleValue) {
    return new LiteralBoolValue(x.value <= y.value);
  }
  if (x is LiteralBoolValue) {
    return new LiteralBoolValue(!x.value);
  }
  if (y is LiteralBoolValue) {
    return new LiteralBoolValue(y.value);
  }
  if (x is LiteralStringValue || y is LiteralStringValue) {
    return new LiteralBoolValue(x.value.toString().compareTo(y.value.toString()) <= 0);
  }
  throw "Value type unrecognized, got ${x.runtimeType} and ${y.runtimeType}";
}

LiteralBoolValue i_ge(LiteralValue x, LiteralValue y) {
  if (x is LiteralDoubleValue && y is LiteralDoubleValue) {
    return new LiteralBoolValue(x.value >= y.value);
  }
  if (x is LiteralBoolValue) {
    return new LiteralBoolValue(x.value);
  }
  if (y is LiteralBoolValue) {
    return new LiteralBoolValue(!y.value);
  }
  if (x is LiteralStringValue || y is LiteralStringValue) {
    return new LiteralBoolValue(x.value.toString().compareTo(y.value.toString()) >= 0);
  }
  throw "Value type unrecognized, got ${x.runtimeType} and ${y.runtimeType}";
}

LiteralStringValue i_concat(LiteralValue x, LiteralValue y) {
  _checkType(x, LiteralStringValue);
  _checkType(y, LiteralStringValue);
  return new LiteralStringValue(x.value + y.value);
}

LiteralDoubleValue i_add(LiteralValue x, LiteralValue y) {
  _checkType(x, LiteralDoubleValue);
  _checkType(y, LiteralDoubleValue);
  return new LiteralDoubleValue(x.value + y.value);
}
LiteralDoubleValue i_sub(LiteralValue x, LiteralValue y) {
  _checkType(x, LiteralDoubleValue);
  _checkType(y, LiteralDoubleValue);
  return new LiteralDoubleValue(x.value - y.value);
}
LiteralDoubleValue i_mul(LiteralValue x, LiteralValue y) {
  _checkType(x, LiteralDoubleValue);
  _checkType(y, LiteralDoubleValue);
  return new LiteralDoubleValue(x.value * y.value);
}
LiteralDoubleValue i_div(LiteralValue x, LiteralValue y) {
  _checkType(x, LiteralDoubleValue);
  _checkType(y, LiteralDoubleValue);
  return new LiteralDoubleValue(x.value / y.value);
}
LiteralDoubleValue i_pow(LiteralValue x, LiteralValue y) {
  _checkType(x, LiteralDoubleValue);
  _checkType(y, LiteralDoubleValue);
  return new LiteralDoubleValue(math.pow(x.value, y.value));
}

LiteralDoubleValue i_percent(LiteralValue x) {
  _checkType(x, LiteralDoubleValue);
  return new LiteralDoubleValue(x.value / 100.0);
}

LiteralDoubleValue i_umin(LiteralValue x) {
  _checkType(x, LiteralDoubleValue);
  return new LiteralDoubleValue(-x.value);
}
LiteralDoubleValue i_uplus(LiteralValue x) {
  _checkType(x, LiteralDoubleValue);
  return new LiteralDoubleValue(x.value);
}

LiteralDoubleValue i_sin(LiteralValue x) {
  _checkType(x, LiteralDoubleValue);
  return new LiteralDoubleValue(math.sin(x.value));
}
LiteralDoubleValue i_cos(LiteralValue x) {
  _checkType(x, LiteralDoubleValue);
  return new LiteralDoubleValue(math.cos(x.value));
}
LiteralDoubleValue i_tan(LiteralValue x) {
  _checkType(x, LiteralDoubleValue);
  return new LiteralDoubleValue(math.tan(x.value));
}
LiteralDoubleValue i_cot(LiteralValue x) {
  _checkType(x, LiteralDoubleValue);
  return new LiteralDoubleValue(1 / math.tan(x.value));
}
LiteralDoubleValue i_asin(LiteralValue x) {
  _checkType(x, LiteralDoubleValue);
  return new LiteralDoubleValue(math.asin(x.value));
}
LiteralDoubleValue i_acos(LiteralValue x) {
  _checkType(x, LiteralDoubleValue);
  return new LiteralDoubleValue(math.acos(x.value));
}
LiteralDoubleValue i_atan(LiteralValue x) {
  _checkType(x, LiteralDoubleValue);
  return new LiteralDoubleValue(math.atan(x.value));
}
LiteralDoubleValue i_atan2(LiteralValue x, LiteralValue y) {
  _checkType(x, LiteralDoubleValue);
  _checkType(y, LiteralDoubleValue);
  return new LiteralDoubleValue(math.atan2(x.value, y.value));
}
LiteralDoubleValue i_acot(LiteralValue x) {
  _checkType(x, LiteralDoubleValue);
  return new LiteralDoubleValue(math.atan(1/x.value));
}

LiteralDoubleValue i_abs(LiteralValue x) {
  _checkType(x, LiteralDoubleValue);
  return new LiteralDoubleValue(x.value.abs());
}
LiteralDoubleValue i_ceiling(LiteralValue x) {
  _checkType(x, LiteralDoubleValue);
  return new LiteralDoubleValue(x.value.ceil().toDouble());
}
LiteralDoubleValue i_exp(LiteralValue x) {
  _checkType(x, LiteralDoubleValue);
  return new LiteralDoubleValue(math.exp(x.value));
}
LiteralDoubleValue i_floor(LiteralValue x) {
  _checkType(x, LiteralDoubleValue);
  return new LiteralDoubleValue(x.value.floor().toDouble());
}
LiteralDoubleValue i_fact(LiteralValue x) {
  _checkType(x, LiteralDoubleValue);
  if (x.value < 0) {
    throw "The parameter of function FACT is $x. It should be greater than or equal to 0.";
  }
  int result = 1;
  for (int i = 1; i <= x.value; i++) {
    result *= i;
  }
  return new LiteralDoubleValue(result.toDouble());
}
LiteralDoubleValue i_int(LiteralValue x) {
  _checkType(x, LiteralDoubleValue);
  return new LiteralDoubleValue(x.value.toInt().toDouble());
}
LiteralBoolValue i_isEven(LiteralValue x) {
  _checkType(x, LiteralDoubleValue);
  return new LiteralBoolValue(x.value % 2 == 0);
}
LiteralBoolValue i_isOdd(LiteralValue x) {
  _checkType(x, LiteralDoubleValue);
  return new LiteralBoolValue(x.value % 2 == 1);
}
LiteralDoubleValue i_ln(LiteralValue x) {
  _checkType(x, LiteralDoubleValue);
  return new LiteralDoubleValue(math.log(x.value));
}
LiteralDoubleValue i_mod(LiteralValue x, LiteralValue y) {
  _checkType(x, LiteralDoubleValue);
  _checkType(y, LiteralDoubleValue);
  return new LiteralDoubleValue(x.value % y.value);
}
LiteralDoubleValue i_power(LiteralValue x, LiteralValue y) {
  _checkType(x, LiteralDoubleValue);
  _checkType(y, LiteralDoubleValue);
  return new LiteralDoubleValue(math.pow(x.value, y.value));
}
LiteralDoubleValue i_radians(LiteralValue x) {
  _checkType(x, LiteralDoubleValue);
  return new LiteralDoubleValue(x.value * math.PI / 180);
}
LiteralDoubleValue i_round(LiteralValue x) {
  _checkType(x, LiteralDoubleValue);
  return new LiteralDoubleValue(x.value.round().toDouble());
}
LiteralDoubleValue i_trunc(LiteralValue x) {
  _checkType(x, LiteralDoubleValue);
  return new LiteralDoubleValue(x.value.truncate().toDouble());
}
LiteralDoubleValue i_sign(LiteralValue x) {
  _checkType(x, LiteralDoubleValue);
  return new LiteralDoubleValue(x.value.sign);
}
LiteralDoubleValue i_sqrt(LiteralValue x) {
  _checkType(x, LiteralDoubleValue);
  return new LiteralDoubleValue(math.sqrt(x.value));
}

LiteralBoolValue i_and(LiteralValue x, LiteralValue y) {
  _checkType(x, LiteralBoolValue);
  _checkType(y, LiteralBoolValue);
  return new LiteralBoolValue(x.value && y.value);
}
LiteralBoolValue i_or(LiteralValue x, LiteralValue y) {
  _checkType(x, LiteralBoolValue);
  _checkType(y, LiteralBoolValue);
  return new LiteralBoolValue(x.value || y.value);
}
LiteralBoolValue i_xor(LiteralValue x, LiteralValue y) {
  _checkType(x, LiteralBoolValue);
  _checkType(y, LiteralBoolValue);
  return new LiteralBoolValue(x.value != y.value);
}

LiteralDoubleValue i_average(List<LiteralValue> args) {
  if (args.length == 0) {
    throw "Wrong number of arguments to AVERAGE. Expected at least 1 argument, but received 0 arguments.";
  }
  double result = 0.0;
  for (LiteralValue arg in args) {
    _checkType(arg, LiteralDoubleValue);
    result += arg.value;
  }
  return new LiteralDoubleValue(result / args.length);
}
LiteralDoubleValue i_max(List<LiteralValue> args) {
  if (args.length == 0) {
    throw "Wrong number of arguments to MAX. Expected at least 1 argument, but received 0 arguments.";
  }
  _checkType(args[0], LiteralDoubleValue);
  double maximum = args[0].value;
  for (LiteralValue arg in args) {
    _checkType(arg, LiteralDoubleValue);
    maximum = math.max(maximum, arg.value);
  }
  return new LiteralDoubleValue(maximum);
}
LiteralDoubleValue i_min(List<LiteralValue> args) {
  if (args.length == 0) {
    throw "Wrong number of arguments to MIN. Expected at least 1 argument, but received 0 arguments.";
  }
  _checkType(args[0], LiteralDoubleValue);
  double minimum = args[0].value;
  for (LiteralValue arg in args) {
    _checkType(arg, LiteralDoubleValue);
    minimum = math.max(minimum, arg.value);
  }
  return new LiteralDoubleValue(minimum);
}
LiteralDoubleValue i_sum(List<LiteralValue> args) {
  if (args.length == 0) {
    throw "Wrong number of arguments to SUM. Expected at least 1 argument, but received 0 arguments.";
  }
  double result = 0.0;
  for (LiteralValue arg in args) {
    _checkType(arg, LiteralDoubleValue);
    result += arg.value;
  }
  return new LiteralDoubleValue(result);
}
LiteralDoubleValue i_product(List<LiteralValue> args) {
  if (args.length == 0) {
    throw "Wrong number of arguments to PRODUCT. Expected at least 1 argument, but received 0 arguments.";
  }
  double result = 1.0;
  for (LiteralValue arg in args) {
    _checkType(arg, LiteralDoubleValue);
    result *= arg.value;
  }
  return new LiteralDoubleValue(result);
}

_checkType(dynamic object, Type expectedType) {
  if (object.runtimeType != expectedType) {
    throw "Expected type $expectedType, but got an ${object.runtimeType} instead";
  }
}