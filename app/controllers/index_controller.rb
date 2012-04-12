class IndexController < ApplicationController

  def index
  end
  
  def short
    @turing_machine = TuringMachine.find_by_short_url(params[:short_url])
    if @turing_machine 
      render 'turing_machines/show'
    else
      redirect_to popular_path, :notice => 'The Turing machine you are looking for does not exist.'
    end
  end
  
  def random
    redirect_to :action => 'show', :controller => 'turing_machines', :id => TuringMachine.random_id
  end
  
  def popular
    @popular = TuringMachine.popular(20)
    @newest = TuringMachine.newest(20)
    @favorited = false if session[:user_id]
  end
  
  def home
    if user_name = params[:user_name]
      @user = User.find_by_name(user_name)
    elsif user_id = session[:user_id]
      @user = User.find_by_id(user_id)
    end
    if @user.nil?
      flash[:notice] = 'The homepage that you are looking for does not exist.'
      redirect_to root_path
    else
      @is_owner = (@user.id == session[:user_id])
      @inventions = @user.turing_machines.reverse
      @favorites = @user.likes.reverse
      @favorited = false if session[:user_id]
    end
  end
  
end
