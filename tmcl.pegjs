// TMCL Program Syntax
// This parses TMCL sources into a simple AST (abstract syntax tree)

{
  var fs = require('fs'),
    path = require('path'),
    sourceFolder = options.sourceFolder || '.',
    self = this

  function include(file) {
    var includePath = path.resolve(sourceFolder, file)
    var _sourceFolder = path.dirname(includePath)
    return self.parse(fs.readFileSync(includePath).toString(),
      { sourceFolder: _sourceFolder })
  }
}


tmcl
  = ( ( include / command / constant / label / comment ) )+

include
  = _ "#include" _ file:[^ \t\r\n]+ _ {
      var includeFile = file.join('')
      return ['include', includeFile, include(includeFile)]
    }

command
  = _ command:(command3 / command2 / command1 / command0) _
  { return ['command', command] }

command3
  = mnemonic:("SAP" / "GAP" / "MVP" / "SGP" / "SIO" / "WAIT" / "SAC" / "SCO") _ parameters:parameter3
  { return [mnemonic].concat(parameters) }

command2
  = mnemonic:("ROL" / "ROR" / "STAP" / "RSAP" / "GGP" / "STGP" / "RSGP" / "RFS" / "GIO" / "CALC" / "JC" / "GCO" / "CCO" / "AAP" / "AGP") _ parameters:parameter2
  { return [mnemonic].concat(parameters) }

command1
  = mnemonic:("MST" / "COMP" / "JA" / "CSUB" / "CALCX" / "CLE") _ parameter:parameter
  { return [mnemonic, parameter]}

command0
  = mnemonic:("RSUB" / "STOP")
  { return [mnemonic] }

parameter3
  = param1:parameter _ "," _ param2:parameter _ "," _ param3:parameter
  { return [param1, param2, param3] }

parameter2
  = param1:parameter _ "," _ param2:parameter
  { return [param1, param2] }

parameter
  = integer
  / identifier

constant
  = _ identifier:identifier _ "=" _ value:integer _
  { return ['constant', identifier, value] }

identifier
  = [a-zA-Z_] [a-zA-Z0-9_]* { return text() }

label
  = _ label:[a-zA-Z0-9_]+ ":" _ { return ['label', label.join('')] }

comment
  = line_comment

line_comment
  = _ "//" _ comment:[^\r\n]* __ { return ['//', comment.join('')] }

integer
  = [0-9]+ { return parseInt(text(), 10) }

_ "whitespace"
  = [ \t\r\n]*

__ "newline"
  = [\r\n]+
