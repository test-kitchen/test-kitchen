# Handler to kill the run if any resource is updated
class UpdatedResources < ::Chef::Handler
  def report
    if updated_resources.size > 0
      puts "First chef run should have reached a converged state."
      puts "Resources updated in a second chef-client run:"
      updated_resources.each do |r|
        puts "- #{r}"
      end
      # exit 203 # chef handler catch Exception instead of StandardException
      Process.kill("KILL", Process.pid)
    end
  end
end
report_handlers << UpdatedResources.new
