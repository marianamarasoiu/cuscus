
class ASTNode {
  toJSONStringRecursive() { return ""; };
}

class ASTFormula extends ASTNode {
  constructor(expression) {
      super();
      this.expression = expression;
  }

  toJSONStringRecursive() {
      return '{"formula": ' + this.expression.toJSONStringRecursive() + '}';
  }
}

class ASTText extends ASTNode {
  constructor(text) {
    super();
    this.text = text;
  }

  toJSONStringRecursive() {
    return '{"text": "' + this.text + '"}';
  }
}

class ASTExpression extends ASTNode {
  constructor() {
      super();
  }
}

class ASTBinaryOperation extends ASTExpression {
  constructor(operation, lhs, rhs) {
      super();
      this.operation = operation;
      this.lhs = lhs;
      this.rhs = rhs;
  }

  toJSONStringRecursive() {
    var operation;
    switch (this.operation) {
      case "=": operation = "eq"; break;
      case "<>": operation = "neq"; break;
      case "<": operation = "lt"; break;
      case ">": operation = "gt"; break;
      case "<=": operation = "le"; break;
      case ">=": operation = "ge"; break;
      case "&": operation = "concat"; break;
      case "+": operation = "add"; break;
      case "-": operation = "sub"; break;
      case "*": operation = "mul"; break;
      case "/": operation = "div"; break;
      case "^": operation = "pow"; break;
      default: throw "Unknown binary operation: " + this.operation;
    }
    var jsonString =
            '{"funcCall": {' +
                    '"functionName": "' + operation + '",' +
                    '"args": [' +
                                  this.lhs.toJSONStringRecursive() + ',' +
                                  this.rhs.toJSONStringRecursive() + ']}}';
    return jsonString;
  }
}

class ASTUnaryOperation extends ASTExpression {
  constructor(operation, operand) {
    super();
    this.operation = operation;
    this.operand = operand;
  }

  toJSONStringRecursive() {
    var operation;
    switch (this.operation) {
      case "%": operation = "percent"; break;
      case "-": operation = "umin"; break;
      case "+": operation = "uplus"; break;
      default: throw "Unknown unary operation: " + this.operation;
    }
    var jsonString =
            '{"funcCall": {' +
                    '"functionName": "' + operation + '",' +
                    '"args": [' + this.operand.toJSONStringRecursive() + ']}}';
    return jsonString;
  }
}

class ASTCall extends ASTExpression {
  constructor(receiver, args) {
    super();
    this.receiver = receiver;
    this.args = args;
  }

  toJSONStringRecursive() {
    var jsonString =
        '{"funcCall": {' +
                    '"functionName": "' + this.receiver.toLowerCase() + '",' +
                    '"args": [';
    for (var i in this.args) {
      jsonString = jsonString + this.args[i].toJSONStringRecursive() + ',';
    }
    if (jsonString.slice(-1) === ',') {
      jsonString = jsonString.slice(0, -1); // remove last comma
    }
    jsonString = jsonString + ']}}';
    return jsonString;
  }
}

class ASTRange extends ASTExpression {
  constructor(sheetName, columnStart, rowStart, columnEnd, rowEnd) {
    super();
    this.sheetName = sheetName;
    this.columnStart = columnStart;
    this.rowStart = rowStart;
    this.columnEnd = columnEnd;
    this.rowEnd = rowEnd;
  }

  toJSONStringRecursive() {
    var jsonString =
          '{"range": {' +
              '"sheetName": "' + this.sheetName + '",' +
              '"columnStart": "' + this.columnStart + '",' +
              '"rowStart": "' + this.rowStart + '",' +
              '"columnEnd": "' + this.columnEnd + '",' +
              '"rowEnd": "' + this.rowEnd + '"' +
          '}}';
    return jsonString;
  }
}

class ASTCell extends ASTExpression {
  constructor(sheetName, column, row) {
    super();
    this.sheetName = sheetName;
    this.column = column;
    this.row = row;
  }

  toJSONStringRecursive() {
    var jsonString =
          '{"cell": {' +
              '"sheetName": "' + this.sheetName + '",' +
              '"column": "' + this.column + '",' +
              '"row": "' + this.row + '"' +
          '}}';
    return jsonString;
  }
}

class ASTInteger extends ASTExpression {
  constructor(value) {
    super();
    this.value = value; // JS int
  }

  toJSONStringRecursive() {
    var jsonString = '{"int": "' + this.value + '"}';
    return jsonString;
  }
}

class ASTFloat extends ASTExpression {
  constructor(value) {
    super();
    this.value = value; // JS float
  }

  toJSONStringRecursive() {
    var jsonString = '{"float": "' + this.value + '"}';
    return jsonString;
  }
}

class ASTBoolean extends ASTExpression {
  constructor(value) {
    super();
    this.value = value; // JS bool
  }

  toJSONStringRecursive() {
    var jsonString = '{"boolean": "' + this.value + '"}';
    return jsonString;
  }
}

class ASTString extends ASTExpression {
  constructor(value) {
    super();
    this.value = value; // JS string
  }

  toJSONStringRecursive() {
    var jsonString = '{"string": ' + this.value + '}';
    return jsonString;
  }
}

var astSemantics = {
  operation: "toAST",
  semantics: {
    Formula_expression: function(_equal, expression) {
      return new ASTFormula(expression.toAST());
    },

    Formula_text: function(text) {
      return new ASTText(text.sourceString);
    },

    ComparisonExpression_eq: function(x, op, y) {
      return new ASTBinaryOperation(op.sourceString, x.toAST(), y.toAST());
    },

    ComparisonExpression_neq: function(x, op, y) {
      return new ASTBinaryOperation(op.sourceString, x.toAST(), y.toAST());
    },

    ComparisonExpression_lt: function(x, op, y) {
      return new ASTBinaryOperation(op.sourceString, x.toAST(), y.toAST());
    },

    ComparisonExpression_gt: function(x, op, y) {
      return new ASTBinaryOperation(op.sourceString, x.toAST(), y.toAST());
    },

    ComparisonExpression_le: function(x, op, y) {
      return new ASTBinaryOperation(op.sourceString, x.toAST(), y.toAST());
    },

    ComparisonExpression_ge: function(x, op, y) {
      return new ASTBinaryOperation(op.sourceString, x.toAST(), y.toAST());
    },

    StringConcatExpression_concat: function(x, op, y) {
      return new ASTBinaryOperation(op.sourceString, x.toAST(), y.toAST());
    },

    AdditiveExpression_add: function(x, op, y) {
      return new ASTBinaryOperation(op.sourceString, x.toAST(), y.toAST());
    },

    AdditiveExpression_sub: function(x, op, y) {
      return new ASTBinaryOperation(op.sourceString, x.toAST(), y.toAST());
    },

    MultiplicativeExpression_mul: function(x, op, y) {
      return new ASTBinaryOperation(op.sourceString, x.toAST(), y.toAST());
    },
  
    MultiplicativeExpression_div: function(x, op, y) {
      return new ASTBinaryOperation(op.sourceString, x.toAST(), y.toAST());
    },
  
    PowerExpression_pow: function(x, op, y) {
      return new ASTBinaryOperation(op.sourceString, x.toAST(), y.toAST());
    },

    PercentExpression_percent: function(x, op) {
      return new ASTUnaryOperation(op.sourceString, x.toAST());
    },
  
    UnaryExpression_unaryPlus: function(op, x) {
      return new ASTUnaryOperation(op.sourceString, x.toAST());
    },

    UnaryExpression_unaryMinus: function(op, x) {
      return new ASTUnaryOperation(op.sourceString, x.toAST());
    },
  
    UnaryExpression_primaryExp: function(exp) {
      return exp.toAST();
    },
  
    UnaryExpression_refExp: function(exp) {
      return exp.toAST();
    },
  
    ReferenceUnionExpression_union: function(x, op, y) {
      return new ASTBinaryOperation(op.sourceString, x.toAST(), y.toAST());
    },

    ReferenceIntersectionExpression_intersection: function(x, op, y) {
      return new ASTBinaryOperation(op.sourceString, x.toAST(), y.toAST());
    },

    RangeExpression_range: function(x, op, y) {
      return new ASTBinaryOperation(op.sourceString, x.toAST(), y.toAST());
    },

    PrimaryExpression_callExp: function(x) {
      return x.toAST();
    },
  
    PrimaryExpression_lit: function(x) {
      return x.toAST();
    },
  
    PrimaryExpression_parens: function(_openParen, x, _closeParen) {
      return x.toAST();
    },

    PrimaryReferenceExpression_callExp: function(x) {
      return x.toAST();
    },
  
    PrimaryReferenceExpression_ref: function(x) {
      return x.toAST();
    },
  
    PrimaryReferenceExpression_parens: function(_openParen, x, _closeParen) {
      return x.toAST();
    },

    CallExpression: function(receiver, args) {
      return new ASTCall(receiver.toAST(), args.toAST());
    },
   
    Arguments: function(_openParen, args, _closeParen) {
      return args.toAST();
    },
  
    Reference_cell: function(optSheetName, column, row) {
      return new ASTRange(optSheetName.toAST(), column.toAST(), row.toAST(), '', '');
    },

    Reference_fullRange: function(optSheetName, columnStart, rowStart, _colon, columnEnd, rowEnd) {
      return new ASTRange(optSheetName.toAST(), columnStart.toAST(), rowStart.toAST(), columnEnd.toAST(), rowEnd.toAST());
    },

    Reference_verticalRange: function(optSheetName, columnStart, _colon, columnEnd) {
      return new ASTRange(optSheetName.toAST(), columnStart.toAST(), null, columnEnd.toAST(), null);
    },

    Reference_horizontalRange: function(optSheetName, rowStart, _colon, rowEnd) {
      return new ASTRange(optSheetName.toAST(), null, rowStart.toAST(), null, rowEnd.toAST());
    },

    Reference_sheetFullRange: function(sheetNameStart, columnStart, rowStart, _colon, sheetNameEnd, columnEnd, rowEnd) {
      return new ASTRange(sheetNameStart.toAST(), columnStart.toAST(), rowStart.toAST(), columnEnd.toAST(), rowEnd.toAST());
    },

    Reference_sheetVerticalRange: function(sheetNameStart, columnStart, _colon, sheetNameEnd, columnEnd) {
      return new ASTRange(sheetNameStart.toAST(), columnStart.toAST(), null, columnEnd.toAST(), null);
    },

    Reference_sheetHorizontalRange: function(sheetNameStart, rowStart, _colon, sheetNameEnd, rowEnd) {
      return new ASTRange(optSheetName.toAST(), null, rowStart.toAST(), null, rowEnd.toAST());
    },
  
    column: function(optDollar, x) {
      return this.sourceString;
    },

    row: function(optDollar, x) {
      return this.sourceString;
    },

    sheetName: function(x, exclamationMark) {
      return x.sourceString;
    },
  
    booleanLiteral: function(x) {
      return new ASTBoolean(this.sourceString === "true");
    },
  
    intLiteral: function(x) {
      return new ASTInteger(parseInt(this.sourceString));
    },
  
    floatLiteral: function(a, _dot, b) {
      return new ASTFloat(parseFloat(this.sourceString));
    },
  
    stringLiteral: function(_openQuote, x, _closeQuote) {
      return new ASTString(this.sourceString);
    },
 
    functionName: function(_name) {
      return this.sourceString;
    },

    text: function(_text) {
      return this.sourceString;
    },

    NonemptyListOf: function(arg, _separator, args) {
      return [arg.toAST()].concat(args.toAST());
    },
  
    EmptyListOf: function() {
      return [];
    }
  }
};

