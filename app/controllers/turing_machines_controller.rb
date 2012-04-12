class TuringMachinesController < ApplicationController

  before_filter :admin_verification, :except => [:show, :new, :edit, :create, :update, :destroy, :favorite, :unfavorite]
  before_filter :authorize, :except => :show
  
  # GET /turing_machines
  # GET /turing_machines.json
  def index
    @turing_machines = TuringMachine.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @turing_machines }
    end
  end

  # GET /turing_machines/1
  # GET /turing_machines/1.json
  def show
    @turing_machine = TuringMachine.find(params[:id])
    @previous = @turing_machine.previous
    @next = @turing_machine.next
    user_id = session[:user_id]
    user = User.find(user_id) if user_id
    @favorited = (user.like_ids.include? @turing_machine.id) if user_id
    @is_owner = @turing_machine.user and user_id and user_id == @turing_machine.user.id

    respond_to do |format|
      format.html # show.html.erb
      format.json {
        render :json => {
          'id' => @turing_machine.id,
          'name' => @turing_machine.name, 
          'short_url' => @turing_machine.short_url, 
          'default_input'=> @turing_machine.default_input,
          'user_id' => @turing_machine.user_id,
          'users_count' => @turing_machine.users_count,
          'definition' => @turing_machine.definition,
          'description' => @turing_machine.description,
          'favorited' => @favorited,
          'href' => @favorited == true ? unfavorite_turing_machine_path(@turing_machine) : favorite_turing_machine_path(@turing_machine)
        }
      }
    end
  end

  # GET /turing_machines/new
  # GET /turing_machines/new.json
  def new
    @turing_machine = TuringMachine.new
    inventions = User.find(session[:user_id]).turing_machines
    @first_invention = !(inventions.any?)
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @turing_machine }
    end
  end

  # GET /turing_machines/1/edit
  def edit
    @turing_machine = TuringMachine.find(params[:id])
    
    if @turing_machine.user and @turing_machine.user.id != session[:user_id]
      flash[:error] = "Only the creator can edit his or her invention."
      redirect_to :controller => 'index', :action => 'home', :user_name => session[:user_name]
      return
    end
    
    respond_to do |format|
      format.html # edit.html.erb
      format.json { render :json => @turing_machine }
    end
  end

  # POST /turing_machines
  # POST /turing_machines.json
  def create
    params[:turing_machine][:user_id] = session[:user_id]
    @turing_machine = TuringMachine.new(params[:turing_machine])

    respond_to do |format|
      if @turing_machine.save
        format.html { redirect_to @turing_machine, :success => 'Turing machine was successfully created.' }
        format.json { render :json => @turing_machine, :status => :created, :location => @turing_machine }
      else
        format.html { render :action => "new" }
        format.json { render :json => @turing_machine.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /turing_machines/1
  # PUT /turing_machines/1.json
  def update
    @turing_machine = TuringMachine.find(params[:id])

    if @turing_machine.user.id != session[:user_id]
      flash[:error] = "Only the creator can edit his or her invention."
      redirect_to :controller => 'index', :action => 'home', :user_name => session[:user_name]
    end

    respond_to do |format|
      if @turing_machine.update_attributes(params[:turing_machine])
        format.html { redirect_to @turing_machine, :success => 'Turing machine was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @turing_machine.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /turing_machines/1
  # DELETE /turing_machines/1.json
  def destroy
    @turing_machine = TuringMachine.find(params[:id])

    if not @turing_machine.user or @turing_machine.user.id != session[:user_id]
      flash[:error] = "Only the creator can delete his or her invention."
    else
      flash[:success] = "One of your inventions has been successfully deleted."
      @turing_machine.destroy
    end
    
    respond_to do |format|
      format.html { redirect_to :controller => 'index', :action => 'home', :user_name => session[:user_name] }
      format.json { head :no_content }
    end
  end
  
  # GET /turing_machine/1/favorite
  # GET /turing_machine/1/favorite.json
  def favorite
    turing_machine = TuringMachine.find(params[:id])
    user = User.find(session[:user_id])
    if not user.like_ids.include? turing_machine.id
      turing_machine.increase_users_count
      user.likes << turing_machine
    end
    
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render :json => { 'favorited' => true, 'href' => unfavorite_turing_machine_path(turing_machine), 'users_count' => turing_machine.users_count } }
    end
  end
  
  # GET /turing_machine/1/unfavorite
  # GET /turing_machine/1/unfavorite.json
  def unfavorite
    turing_machine = TuringMachine.find(params[:id])
    user = User.find(session[:user_id])
    if user.like_ids.include? turing_machine.id
      turing_machine.decrease_users_count
      user.likes.delete turing_machine
    end
    
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render :json => { 'favorited' => false,'href' => favorite_turing_machine_path(turing_machine), 'users_count' => turing_machine.users_count } }
    end    
  end
  
end
