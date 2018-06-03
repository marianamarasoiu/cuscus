var formulaGrammar =
`
Spreadsheet {
  Formula
    = "=" Expression           -- expression
    | ~"=" text                -- text
    
  Expression (an expression)
    = ComparisonExpression
  
  ComparisonExpression
    = ComparisonExpression "=" StringConcatExpression       -- eq
    | ComparisonExpression "<>" StringConcatExpression      -- neq
    | ComparisonExpression "<" StringConcatExpression       -- lt
    | ComparisonExpression ">" StringConcatExpression       -- gt
    | ComparisonExpression "<=" StringConcatExpression      -- le
    | ComparisonExpression ">=" StringConcatExpression      -- ge
    | StringConcatExpression

  StringConcatExpression
    = StringConcatExpression "&" AdditiveExpression         -- concat
    | AdditiveExpression

  AdditiveExpression
    = AdditiveExpression "+" MultiplicativeExpression       -- add
    | AdditiveExpression "-" MultiplicativeExpression       -- sub
    | MultiplicativeExpression

  MultiplicativeExpression
    = MultiplicativeExpression "*" PowerExpression          -- mul
    | MultiplicativeExpression "/" PowerExpression          -- div
    | PowerExpression
    
  PowerExpression
    = PowerExpression "^" PercentExpression                 -- pow
    | PercentExpression
  
  PercentExpression
  	= PercentExpression "%"                                 -- percent
    | UnaryExpression

  UnaryExpression
    = "-"    UnaryExpression  -- unaryMinus
    | "+"    UnaryExpression  -- unaryPlus
    | PrimaryExpression       -- primaryExp
    | ReferenceExpression     -- refExp

  ReferenceExpression
  	= RangeExpression

  ReferenceUnionExpression
  	= ReferenceUnionExpression "," ReferenceIntersectionExpression -- union
    | ReferenceIntersectionExpression
    
  ReferenceIntersectionExpression
  	= ReferenceIntersectionExpression "~" RangeExpression    -- intersection
    | RangeExpression
    
  RangeExpression
  	= RangeExpression ":" PrimaryReferenceExpression -- range
    | PrimaryReferenceExpression
    
  PrimaryExpression
  	= CallExpression          -- callExp
    | literal                 -- lit
    | "(" Expression ")"      -- parens
    
  PrimaryReferenceExpression
  	= CallExpression                   -- callExp
    | Reference                        -- ref
    | "(" ReferenceExpression ")"      -- parens

  CallExpression = functionName Arguments
    
  Arguments
    = "(" ListOf<Expression, ","> ")"

  Reference
  	= sheetName         row  ":" sheetName        row    -- sheetHorizontalRange
    | sheetName  column      ":" sheetName column        -- sheetVerticalRange
    | sheetName  column row  ":" sheetName column row    -- sheetFullRange
    | sheetName?        row  ":"                  row    -- horizontalRange
    | sheetName? column      ":"           column        -- verticalRange
    | sheetName? column row  ":"           column row    -- fullRange
    | sheetName? column row                              -- cell

  column = "$"? letter+
  row = "$"? digit+
  sheetName = alnum+ "!"
  
  literal = booleanLiteral | numLiteral | stringLiteral
  numLiteral = floatLiteral | intLiteral
  booleanLiteral = ("true" | "false")
  floatLiteral = digit* "." digit+
  intLiteral = digit+

  stringLiteral = "\\"" stringCharacter* "\\""
  stringCharacter
  	= ~("\\"") any -- noQuote
    | "\\"\\""      -- doubleQuote

  functionName = letter+

  text = any*
}
`;