'use strict'

var fs = require('fs'),
  path = require('path')
var PEG = require('pegjs')

console.log('TMCL.js Compiler 0.0.1')

var sourceFile = process.argv[2]

// preprocess the given AST and update the program
function preprocess(ast, program) {
  var address = 0
  // store contants and labels
  ast.forEach(function(astElement) {
    var type = astElement[0]
    switch (type) {
      case 'include':
        preprocess(astElement[2], program)
        break;
      case 'constant':
        program.constants[astElement[1]] = astElement[2]
        break;
      case 'label':
        program.symbols[astElement[1]] = address
        break;
      case 'command':
        program.instructions.push(astElement[1])
        address++
        break;
      default:
        break;
    }
  })
}

// dump the program
function dump(program) {
  console.log('// Symbols: ')
  for (var symbol in program.symbols) {
    console.log(symbol + ': ' + program.symbols[symbol])
  }

  console.log('// Instructions: ')
  var address = 0
  program.instructions.forEach(function(instruction) {
    console.log(address++ + ': ' + instruction.join(', '))
  })
}

// compile the program into a binary
function compile(program) {
  // TODO
}


fs.readFile('tmcl.pegjs', 'utf-8', function(err, contents) {
  if (!err) {
    var parser = PEG.buildParser(contents)

    console.log('Parsing file ', sourceFile)

    var sourceFolder = path.dirname(sourceFile)
    fs.readFile(sourceFile, 'utf-8', function(err, contents) {
      if (!err) {
        var result = parser.parse(contents, { sourceFolder : sourceFolder })

        var program = {
          constants: {},
          symbols: {},
          instructions: []
        }

        preprocess(result, program)
        dump(program)
        var binary = compile(program)

      } else {
        console.log('Error reading TMCL code', err)
      }
    })
  } else {
    console.log('Error reading TMCL parser definition', err)
  }
})
