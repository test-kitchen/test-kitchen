# frozen_string_literal: true

require "fileutils"

check = ARGV.delete("--check")
abort "Usage: ruby #{File.basename(__FILE__)} [--check] DRIVER_CHECKOUT..." if ARGV.empty?

source = File.join(__dir__, "shared")
files = Dir.glob("**/*", File::FNM_DOTMATCH, base: source).select do |path|
  File.file?(File.join(source, path))
end

in_sync = true
ARGV.each do |checkout|
  destination = File.join(checkout, "examples", "apache2")
  abort "Missing Apache example: #{destination}" unless File.directory?(destination)

  files.each do |path|
    original = File.join(source, path)
    copy = File.join(destination, path)
    if check
      next if File.file?(copy) && FileUtils.compare_file(original, copy)

      warn "Fixture differs: #{copy}"
      in_sync = false
    else
      FileUtils.mkdir_p(File.dirname(copy))
      FileUtils.cp(original, copy)
    end
  end
end
exit in_sync
