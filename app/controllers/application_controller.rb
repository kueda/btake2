class ApplicationController < ActionController::Base
  protect_from_forgery

  def after_sign_in_path_for(user)
    root_url
  end

  def after_sign_up_path_for(user)
    root_url
  end

  def render_404
    raise ActionController::RoutingError.new('Not Found')
  end
end
