class AdminController < ApplicationController
  
  before_filter :authorize, :except => [:login, :logout, :signup]
  
  def login
    if request.post?
      user = User.authenticate(params[:name], params[:password])
      if user
        session[:user_id] = user.id
        session[:user_name] = user.name
        redirect_to :action => "home", :controller => "index", :user_name => session[:user_name]
      else
        flash.now[:notice] = "Invalid username/password combination."
      end
    end
    flash.now[:info] = "You've logged in as #{session[:user_name]}." if session[:user_name]
  end

  def logout
    session[:user_id] = nil
    session[:user_name] = nil
    flash[:info] = "Logged out."
    redirect_to login_path
  end
  
  def signup
    if request.post?
      @code = Invitation.find_by_code(params[:invitation])
      @user = User.new(params[:user])
      if @code and @user.save
        @user.add_invitations()
        @code.destroy
        flash[:info] = "Account has been successfully created."
        redirect_to login_path
      else
        @code_errors = ["Invitation is invalid."]
        flash.now[:notice] = "Errors occurred."
      end
    else
      @user = User.new
    end
  end

  def account
    @user = User.find_by_id(session[:user_id])
    @invitation_code = @user.invitations
    if request.put?
      if params[:category] == 'password'
        if User.authenticate(@user.name, params[:current_password])
          if @user.update_attributes(params[:user])
            flash.now[:info] = "Password has been updated."
          else
            flash.now[:notice] = "Errors occurred."
          end
        else
          @current_password_errors = ['Password is wrong.']
          flash.now[:notice] = "Errors occurred."
        end
      else
        if @user.update_attributes(params[:user])
          flash.now[:info] = "Username has been updated."
        else
          flash.now[:notice] = "An error occurred."
        end
      end
    end
    render :account, :locals => { :category => params[:category] }
  end
end
