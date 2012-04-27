class Chef::Recipe
  def recipe_for_project?(project_name)
    run_context.cookbook_collection['kitchen'].recipe_files.any? do |rf|
      rf =~ Regexp.new(project_name)
    end
  end
end
