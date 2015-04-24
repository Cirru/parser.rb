require "bundler/gem_tasks"

require "json"

require "cirru/parser"

desc 'nothing'
task 'nothing' do
  res = Cirru::Parser.parse('code', 'file')
end

desc "test"
task "test" do
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
