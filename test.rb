
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")

require 'cirru/parser'

code = IO.read "examples/line.cirru"
res = Cirru::Parser.parse(code, 'file')
p 'parsing result:', res
