require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::MembersController do
  scenario :users
  
  before do
    login_as :developer
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
        controller.should_receive(:include_javascript).with("controls")
        do_get
      end

      it "includes stylesheets" do
        controller.should_receive(:include_stylesheet).with("admin/member")
        do_get
      end
    end
  end
  
  describe "handling POST create" do
    def do_post(options = {})   #creates a new member
      post :create, :member => { :name => 'test', :email => 'test@example.com',
        :password => 'testpass', :password_confirmation => 'testpass', :company => 'test&co' }.merge(options)
    end
    
    it "creates member" do
      lambda do
        do_post
        response.should be_redirect
      end.should change(Member, :count).by(1)
    end
    
    ['email', 'name', 'password', 'password_confirmation', 'company' ].each do |required_attribute|
      it "requires #{required_attribute} on create" do
        lambda do
          do_post(required_attribute.to_sym => nil)
          assigns[:member].errors.on(required_attribute).should_not be_nil
          response.should be_success
        end.should_not change(Member, :count)
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
  
  describe "handling GET edit" do
    before do
      @member = mock_model(Member, :id => 1)
      Member.stub!(:find).and_return(@member)
    end

    def do_get
      get :edit
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
      @member = mock_model(Member, :id => 1, :name => 'name', :company => 'company', :email => 'email@example.com', :password => 'pass', :password_confirmation => 'pass')
      Member.stub!(:find).and_return(@member)
    end
    
    def do_put(options={})
      put :update, :member => {:name => 'name_test', :company => 'company_test', :email => 'email_test@example.com', :password => 'pass_test', :password_confirmation => 'pass_test'}.merge(options)
    end
    
    it "allows editing" do
      @member.should_receive(:update_attributes).and_return(true)
      lambda do
        do_put
        response.should be_redirect
      end.should_not change(Member, :count)
    end

    ['name', 'email', 'company', 'password', 'password_confirmation'].each do |required_attribute|
      it "requires #{required_attribute} on update" do
        @member.should_receive(:update_attributes).and_return(false)
        do_put(required_attribute.to_sym => nil)
        response.should render_template(:edit)
      end
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
      request.cookies[key] = CGI::Cookie.new('name' => key, 'value' => value)
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
      response.cookies['page'].should == ['99']
    end
    
    it "should reset list_params when params[:reset] == 1" do
      set_cookie('page', '98')
      do_get(:reset => 1)
      filter_by_params
      response.cookies['page'].should == ["1"]
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
      get :auto_complete_for_member_company, :object => "member", :method => "company"
    end
    
    it "should be succesfull" do
      do_get
      response.should be_success
    end
    
  end
end