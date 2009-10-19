
require 'tiamat'
require 'pure/parser/ruby_parser'

Pure.parser = Pure::Parser::RubyParser
Tiamat.compiler = Pure.parser.compiler
