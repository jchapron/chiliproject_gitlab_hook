ActionController::Routing::Routes.draw do |map|
  map.connect 'hooks/gitlab', :controller => 'hook', :action => 'create'
end