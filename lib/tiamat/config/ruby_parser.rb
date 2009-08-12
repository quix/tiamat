
require 'tiamat'
require 'pure/parser/ruby_parser'

Pure.parser = Pure::Parser::RubyParser
Tiamat.compiler = %w[Pure::Compiler::RubyParser pure/compiler/ruby_parser]
