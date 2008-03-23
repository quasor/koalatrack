# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  # protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  include SslRequirement
  # If you want "remember me" functionality, add this before_filter to Application Controller
  # before_filter :login_from_cookie  
end