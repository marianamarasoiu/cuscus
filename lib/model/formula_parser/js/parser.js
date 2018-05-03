
var grammar = ohm.grammar(formulaGrammar);
var semantics = grammar.createSemantics().addOperation(astSemantics.operation, astSemantics.semantics);

var parseFormula = function(formula) {
  var codeMatch = grammar.match(formula);
  var codeSemantics = semantics(codeMatch).toAST();
  return codeSemantics.toJSONStringRecursive();
}
