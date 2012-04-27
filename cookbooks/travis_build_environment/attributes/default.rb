default[:travis_build_environment] = {
  :user                 => "vagrant",
  :group                => "vagrant",
  :home                 => "/home/vagrant",
  :hosts                => Hash.new,
  :builds_volume_size   => "350m",
  :use_tmpfs_for_builds => true
}
