require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::MembersController do
  dataset :users
  
  before :each do
    login_as :designer
  end
  
  describe "handling GET index" do
    before do
      @members = (1..10).map {|i| mock_model(Member) }
      @companies = (1..4).map {|i| mock_model(Member)}
      
      Member.stub!(:members_paginate).and_return(@members)
      Member.stub!(:find_all_group_by_company).and_return(@companies)
      @list_params = mock("list_params")
      controller.stub!(:filter_by_params)
    end
    
    def do_get
      get :index
    end
    
    it "should be succesful" do
      do_get
      response.should be_success
    end
    
    it "should render index template" do
      do_get
      response.should render_template('index')
    end
    
    it "should parse list_params" do
      controller.should_receive(:filter_by_params).with(Admin::MembersController::FILTER_COLUMNS)
      do_get
    end
  
    it "should find all saved items with list_params" do
      controller.should_receive(:list_params).and_return(@list_params)
      Member.should_receive(:members_paginate).with(@list_params).and_return(@members)
      do_get
    end
  
    it "should assign the found saved items for the view" do
      do_get
      assigns[:members].should == @members
    end
    
    it "should assign the found urls for the view" do
      do_get
      assigns[:companies].should == @companies  
    end
    
    describe "including member assets" do
      it "includes javascripts" do
        controller.should_receive(:include_javascript).with("admin/controls")
        do_get
      end

      it "includes stylesheets" do
        controller.should_receive(:include_stylesheet).with("admin/member")
        do_get
      end
    end
  end
  
  describe "handling GET new" do
    def do_get
      get :new
    end
    
    it "should be succesful" do
      do_get
      response.should be_success
    end
    
    it "renders new template" do
      do_get
      response.should render_template('new')
    end
  end
  
  describe "handling POST create" do
    
    before do
      @member = mock_model(Member, :save => true)
      Member.stub!(:new).and_return(@member)
    end
    
    def do_post(options = {})
      post :create, :member => options
    end
    
    it "creates a new member from params" do
      Member.should_receive(:new).with("email" => 'test@email.com')
      do_post(:email => 'test@email.com')
    end
    
    it "redirects on success" do
      do_post
      response.should be_redirect
    end
    
    it "assigns flash notice on success" do
      do_post
      flash[:notice].should == "Account created."
    end
    
    it "renders new template on failure" do
      @member.should_receive(:save).and_return(false)
      do_post
      response.should render_template(:new)
    end
    
    it "assigns flash error on failure" do
      @member.should_receive(:save).and_return(false)
      do_post
      flash[:error].should == "Account not created."
    end
  end
  
  describe "handling GET edit" do
    before do
      @member = mock_model(Member, :id => 1)
      Member.stub!(:find).and_return(@member)
    end

    def do_get
      get :edit, :id => @member.id
    end
    
    it "should be succesful" do
      do_get
      response.should be_success
    end
    
    it "renders edit template" do
      do_get
      response.should render_template('edit')
    end
  end
  
  describe "handling PUT update" do
    before do
      @member = mock_model(Member, :update_attributes => true)
      Member.stub!(:find).and_return(@member)
    end
    
    def do_put(options={})
      put :update, {:id => @member.id}.merge(options)
    end
    
    it "finds the corresponding member" do
      Member.should_receive(:find).with(@member.id.to_s).and_return(@member)
      do_put
    end
    
    it "updates the member attributes" do
      @member.should_receive(:update_attributes).and_return(true)
      do_put
    end
    
    it "redirects on success" do
      do_put
      response.should be_redirect
    end
    
    it "assigns the flash notice on success" do
      do_put
      flash[:notice].should == "Account edited."
    end
    
    it "renders the edit template on failure" do
      @member.should_receive(:update_attributes).and_return(false)
      do_put
      response.should render_template(:edit)
    end
    
    it "assigns flash error on failure" do
      @member.should_receive(:update_attributes).and_return(false)
      do_put
      flash[:error].should == "Account not edited."
    end
  end
    
  describe "handling DELETE destroy" do
    
    before do
      @member = mock_model(Member)
      Member.stub!(:find).and_return(@member)
      @member.stub!(:destroy)
    end
    
    def do_delete
      delete :destroy, :id => @member.id
    end
    
    it "redirects on success" do
      do_delete
      response.should be_redirect
    end
    
    it "find the coresponding member" do
      Member.should_receive(:find).with(@member.id.to_s).and_return(@member)
      do_delete
    end
    
    it "destroys the member" do
      @member.should_receive(:destroy)
      do_delete
    end
    
    it "assigns the flash notice" do
      do_delete
      flash[:notice].should == "Member deleted!"
    end
  end
  
  describe "handling GET reset_password" do
    before do
      @member = mock_model(Member)
      Member.stub!(:find).and_return(@member)
    end
    
    def do_get
      get :reset_password, :id => @member.id
    end
    
    it "is succesful" do
      do_get
      response.should be_success
    end
    
    it "finds the coresponding member" do
      Member.should_receive(:find).with(@member.id.to_s).and_return(@member)
      do_get
    end
    
    it "renders reset_password template" do
      do_get
      response.should render_template('reset_password')
    end
  end
  
  describe "handling POST send_email" do
    before do
      @member = mock_model(Member, :name => "test_name")
      Member.stub!(:find).and_return(@member)
      @member.stub!(:email_new_password)
    end
    
    def do_post
      post :send_email, :id => @member.id
    end
    
    it "redirects on success" do
      do_post
      response.should redirect_to('admin/members')
    end
    
    it "finds the coresponding member" do
      Member.should_receive(:find).with(@member.id.to_s).and_return(@member)
      do_post
    end
    
    it "emails new password" do
      @member.should_receive(:email_new_password)
      do_post
    end
    
    it "assigns flash notice" do
      do_post
      flash[:notice].should == "The password for #{@member.name} was reset and sent via email."
    end
  end
  
  describe "handling POST import_from_csv" do
    
    before do
      @imported = 1
      @duplicate = 1
      Member.stub!(:import_members).and_return([@imported,@duplicate,[]])
    end
    
    def do_post
      post :import_from_csv, :file => { :csv => 'csv_data' }
    end
    
    it "imports members from CSV" do
      Member.should_receive(:import_members).with('csv_data')
      do_post
    end
    
    it "it redirects to members path" do
      do_post
      response.should redirect_to('/admin/members')
    end
    
    it "renders the edit invalid members template if there are invalid rows in the CSV" do
      Member.stub!(:import_members).and_return([@imported, @duplicate, ['something']])
      do_post
      response.should render_template("edit_invalid")
    end
    
    it "assigns flash notice" do
      do_post
      flash[:notice].should == "Imported #{@imported} members. " + "#{@duplicate} members were duplicate."
    end
  end
  
  describe "handling POST update_invalid" do
    
    before do
      @imported = 1
      Member.stub!(:update_invalid_members).and_return([@imported, []])
    end
    
    def do_post
      post :update_invalid
    end
    
    it "imports members from CSV" do
      Member.should_receive(:update_invalid_members)
      do_post
    end
    
    it "it redirects to members path" do
      do_post
      response.should be_redirect
    end
    
    it "renders the edit invalid members template if there are invalid rows in the CSV" do
      Member.stub!(:update_invalid_members).and_return([@imported, ['something']])
      do_post
      response.should render_template("edit_invalid")
    end
    
    it "assigns flash notice" do
      do_post
      flash[:notice].should == "Imported #{@imported} members."
    end
  end
  
  describe "handling POST activate" do
    
    before do
      @member = mock_model(Member, :name => 'test_name', :active => false)
      Member.stub!(:find).and_return(@member)
      @member.stub!(:activate!)
    end
    
    def do_post
      post :activate, :id => @member.id
    end
    
    it "redirects on success" do
      do_post
      response.should be_redirect
    end
    
    it "finds the coresponding member" do
      Member.should_receive(:find).with(@member.id.to_s).and_return(@member)
      do_post
    end
    
    it "activates the member" do
      @member.should_receive(:activate!)
      do_post
    end
    
    it "assigns flash notice" do
      do_post
      flash[:notice].should == "Member #{@member.name} has been activated!"
    end
  end
  
  describe "handling POST deactivate" do
    
    before do
      @member = mock_model(Member, :name => 'test_name', :active => true)
      Member.stub!(:find).and_return(@member)
      @member.stub!(:deactivate!)
    end
    
    def do_post
      post :deactivate, :id => @member.id
    end
    
    it "redirects on success" do
      do_post
      response.should be_redirect
    end
    
    it "finds the coresponding" do
      Member.should_receive(:find).with(@member.id.to_s).and_return(@member)
      do_post
    end
    
    it "deactivates the member" do
      @member.should_receive(:deactivate!)
      do_post
    end
    
    it "assigns flash notice" do
      do_post
      flash[:notice].should == "Member #{@member.name} has been deactivated!"
    end
  end
  
  describe "parsing list_params" do
    def do_get(options={})
      get :index, options
    end
  
    def filter_by_params(args=[])
      @controller.send(:filter_by_params, args)
    end
    
    def list_params
      @controller.send(:list_params)
    end
    
    def set_cookie(key, value)
      # request.cookies[key] = CGI::Cookie.new('name' => key, 'value' => value)
      request.cookies[key] = value
    end
  
    it "should have default set of params" do
      do_get
      filter_by_params
      [:page, :sort_by, :sort_order].each {|p| response.cookies.keys.should include(p.to_s)}
    end
    
    it "should take arbitrary params" do
      do_get(:name => 'Blah', :test => 10)
      filter_by_params([:name, :test])
      [:name, :test].each {|p| response.cookies.keys.should include(p.to_s)}
    end
        
    it "should load list_params from cookies by default" do
      set_cookie('page', '98')
      do_get
      filter_by_params
      list_params[:page].should == '98'
    end
    
    it "should prefer request params over cookies" do
      set_cookie('page', '98')
      do_get(:page => '99')
      filter_by_params
      list_params[:page].should == '99'
    end
    
    it "should update cookies with new values" do
      set_cookie('page', '98')
      do_get(:page => '99')
      filter_by_params
      response.cookies['page'].should == '99'
    end
    
    it "should reset list_params when params[:reset] == 1" do
      set_cookie('page', '98')
      do_get(:reset => 1)
      filter_by_params
      response.cookies['page'].should == "1"
    end
    it "should set params[:page] if loading from cookies (required for will_paginate to work)" do
      set_cookie('page', '98')
      do_get
      filter_by_params
      params[:page].should == '98'
    end
  end
  
  describe "autocomplete" do

    def do_get
      get :auto_complete_for_member_company, "member" => {"company" => 'asdf'}
    end
    
    it "should be succesfull" do
      do_get
      response.should be_success
    end
  end
end