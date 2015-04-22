require "bundler/gem_tasks"

require "cirru/parser"
require "json"

desc "demo"
task "demo" do
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

  names.each do |name|
    code = IO.read "examples/#{name}.cirru"
    ast = JSON.parse (IO.read "ast/#{name}.json")
    puts JSON.pretty_generate(ast)
  end
end
