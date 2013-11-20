require 'redmine'

Redmine::Plugin.register :chiliproject_gitlab_hook do
  name 'Chiliproject Gitlab Hook plugin'
  author 'Jerome Chapron'
  description 'Allows integration of commits in issue log history via gitlab web hook'
  version '0.0.1'
  url 'https://github.com/jchapron/chiliproject_gitlab_hook'
  author_url 'https://github.com/jchapron'
  settings :default => {'empty' => true}, :partial => 'settings/gitlab_settings'
end
