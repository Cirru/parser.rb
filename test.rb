
require "json"

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")

require 'cirru/parser'

names = [
  'comma',
  'demo',
  'folding',
  'html',
  'indent',
  'line',
  'parentheses',
  'quote',
  'spaces',
  'unfolding'
]

def test(name)
  code = IO.read "examples/#{name}.cirru"
  ast = Cirru::Parser.pare(code, 'file')
  genereated = JSON.generate ast
  expected = JSON.generate JSON.parse(IO.read("ast/#{name}.json"))
  if genereated == expected
    print "\nok:\t", name
  else
    print "\nfailed:\t", name
    print genereated
  end
end

names.each do |name|
  test name
end
