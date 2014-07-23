ignore %r{^\.gem/}

group :red_green_refactor, halt_on_fail: true do
  guard 'minitest' do
    watch(%r|^spec/(.*)_spec\.rb|)
    watch(%r|^lib/(.*)([^/]+)\.rb|)     { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
    watch(%r|^spec/spec_helper\.rb|)    { "spec" }
  end

  guard :rubocop, all_on_start: false, keep_failed: false, cli: "-r finstyle" do
    watch(%r{.+\.rb$})
    watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
  end
end

cucumber_cli = '--no-profile --color --format progress --strict'
cucumber_cli += ' --tags ~@spawn' if RUBY_PLATFORM =~ /mswin|mingw|windows/
guard 'cucumber', all_on_start: false, cli: cucumber_cli do
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$})          { 'features' }
  watch(%r{^features/step_definitions/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'features' }
end

guard 'yard', port: '8808' do
  watch(%r{lib/.+\.rb})
end
