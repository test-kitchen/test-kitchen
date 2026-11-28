apt_update "apache2 package index" do
  action :periodic
end

package "apache2"

service "apache2" do
  action %i{enable start}
end
