class ApplicationController < ActionController::Base
  protect_from_forgery
  
protected
  def authorize
    unless User.find_by_id(session[:user_id])
      flash[:notice] = "Please log in first."
      redirect_to login_path
    end
  end
  
  def admin_verification
    unless session[:user_name] == 'libragold'
      flash[:notice] = "The page that you were looking for is protected."
      redirect_to home_path
    end
  end
    
end