guard 'minitest' do
  watch(%r|^spec/(.*)_spec\.rb|)
  watch(%r|^lib/(.*)([^/]+)\.rb|)     { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r|^spec/spec_helper\.rb|)    { "spec" }
end

cucumber_cli = '--no-profile --color --format progress --strict'
cucumber_cli += ' --tags ~@spawn' if RUBY_PLATFORM =~ /mswin|mingw|windows/
guard 'cucumber', cli: cucumber_cli do
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$})          { 'features' }
  watch(%r{^features/step_definitions/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'features' }
end

guard 'yard', port: '8808' do
end
