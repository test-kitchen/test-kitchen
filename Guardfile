# -*- encoding: utf-8 -*-
ignore %r{^\.gem/}

def rubocop_opts
  { all_on_start: false, keep_failed: false, cli: "-r finstyle" }
end

def cucumber_opts
  cucumber_cli = "--no-profile --color --format progress --strict"
  cucumber_cli += " --tags ~@spawn" if RUBY_PLATFORM =~ /mswin|mingw|windows/

  { all_on_start: false, cli: cucumber_cli }
end

def yard_opts
  { port: "8808" }
end

group :red_green_refactor, halt_on_fail: true do
  guard :minitest do
    watch(%r{^spec/(.*)_spec\.rb})
    watch(%r{^lib/(.*)([^/]+)\.rb})     { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
    watch(%r{^spec/spec_helper\.rb})    { "spec" }
  end

  guard :rubocop, rubocop_opts do
    watch(/.+\.rb$/)
    watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
  end
end

guard :cucumber, cucumber_opts do
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$}) { "features" }
  watch(%r{^features/step_definitions/(.+)_steps\.rb$}) do |m|
    Dir[File.join("**/#{m[1]}.feature")][0] || "features"
  end
end

guard :yard, yard_opts do
  watch(%r{lib/.+\.rb})
end
