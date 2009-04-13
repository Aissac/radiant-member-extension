require File.dirname(__FILE__) + '/../spec_helper'

describe MemberSessionsController do
  before do
    MemberExtensionSettings.defaults[:login_path] = '/login'
    MemberExtensionSettings.defaults[:home_path] = "/home"
    @member  = mock_model(Member, :id => 1, :email => 'test@test.com', :name => 'Member Name')
    @login_params = { :email => 'test@example.com', :password => 'test' }
    Member.stub!(:authenticate).with(@login_params[:email], @login_params[:password]).and_return(@member)
  end
  
  def do_create(options={})
    post :create, @login_params.merge(options)
  end

  describe "on succesful login," do
    
    before do
      @member.stub!(:remember_me)
      @member.stub!(:refresh_token) 
      @member.stub!(:forget_me)
    end
    
    describe "i have no cookie token and I don't want to be remembered" do
      before do
        @member.stub!(:remember_token).and_return('nil') 
        @member.stub!(:remember_token_expires_at).and_return(15.minutes.from_now)
        @member.stub!(:remember_token?).and_return(false)
        @login_params[:remember_me] = '0'
      end
      it "kills existing login" do
        controller.should_receive(:logout_keeping_member_session!)
        do_create
      end    
      
      it "authorizes me" do
        do_create
        controller.send(:member_authorized?).should be_true
      end    
      
      it "logs me in" do
        do_create
        controller.send(:member_logged_in?).should  be_true 
      end
      
      it "greets me nicely" do
        do_create
        response.flash[:notice].should =~ /success/i
      end
      
      it "sets/resets/expires cookie" do
        controller.should_receive(:handle_remember_member_cookie!).with(false)
        do_create
      end
      
      it "sends a cookie" do 
        controller.should_receive(:send_remember_member_cookie!)
        do_create
      end
      
      it 'redirects to members_home' do 
        do_create
        response.should redirect_to("/home")
      end
      
      it "does not reset my session" do 
        controller.should_not_receive(:reset_session).and_return nil
        do_create
      end
      
      it 'does not make new token' do 
        @member.should_not_receive(:remember_me)
        do_create
      end
      
      it 'does not refresh token' do 
        @member.should_not_receive(:refresh_token)
        do_create
      end 
      
      it 'kills user token' do @member.should_receive(:forget_me)
        do_create
      end
    end #i have no cookie token and I don't want to be remembered
    
    describe "i have a valid cookie token and I don't want to be remembered" do
      before do
        @member.stub!(:remember_token).and_return('valid_token') 
        @member.stub!(:remember_token_expires_at).and_return(15.minutes.from_now)
        @member.stub!(:remember_token?).and_return(true)
        @login_params[:remember_me] = '0'    
      end
      it "kills existing login" do
        controller.should_receive(:logout_keeping_member_session!)
        do_create
      end    
      
      it "authorizes me" do
        do_create
        controller.send(:member_authorized?).should be_true
      end    
      
      it "logs me in" do
        do_create
        controller.send(:member_logged_in?).should be_true 
      end
      
      it "greets me nicely" do
        do_create
        response.flash[:notice].should =~ /success/i
      end
      
      it "sets/resets/expires cookie" do
        controller.should_receive(:handle_remember_member_cookie!).with(false)
        do_create
      end
      
      it "sends a cookie" do 
        controller.should_receive(:send_remember_member_cookie!)
        do_create
      end
      
      it 'redirects to members_home' do 
        do_create
        response.should redirect_to("/home")
      end
      
      it "does not reset my session" do 
        controller.should_not_receive(:reset_session).and_return nil
        do_create
      end
      
      it 'does not make new token' do 
        @member.should_not_receive(:remember_me)
        do_create
      end
      
      it "sets an auth cookie" do
        do_create
      end
    end #i have a valid cookie token and I don't want to be remembered
    
    describe "the cookie token doesn't matter, I want to be remembered" do
      before do
        @member.stub!(:remember_token).and_return('nil') 
        @member.stub!(:remember_token_expires_at).and_return(15.minutes.from_now)
        @member.stub!(:remember_token?).and_return(false)
        @login_params[:remember_me] = '1'
      end
      it "kills existing login" do
         controller.should_receive(:logout_keeping_member_session!)
         do_create
       end    

       it "authorizes me" do
         do_create
         controller.send(:member_authorized?).should be_true
       end    

       it "logs me in" do
         do_create
         controller.send(:member_logged_in?).should  be_true 
       end

       it "greets me nicely" do
         do_create
         response.flash[:notice].should =~ /success/i
       end

       it "sets/resets/expires cookie" do
         controller.should_receive(:handle_remember_member_cookie!).with(true)
         do_create
       end

       it "sends a cookie" do 
         controller.should_receive(:send_remember_member_cookie!)
         do_create
       end

       it 'redirects to members_home' do 
         do_create
         response.should redirect_to("/home")
       end

       it "does not reset my session" do 
         controller.should_not_receive(:reset_session).and_return nil
         do_create
       end
       
       it 'makes a new token' do 
         @member.should_receive(:remember_me)
         do_create
       end 
       
       it "does not refresh token" do
         @member.should_not_receive(:refresh_token)
         do_create
       end
       
       it "sets an auth cookie" do 
         do_create
       end
    end
  end # on succesful login
  
  describe "on failed login" do
    before do
      Member.should_receive(:authenticate).with(anything(), anything()).and_return(nil)
    end
    it 'logs out keeping session' do 
      controller.should_receive(:logout_keeping_member_session!)
      do_create
    end
    
    it 'flashes an error' do
      do_create
      flash[:error].should =~ /Couldn't log you in as 'test@example.com'/ 
    end
    
    it 'redirects on failure' do
      do_create
      response.should redirect_to("/login")
    end
    
    it "doesn't log me in" do
      do_create
      controller.send(:member_logged_in?).should == false
    end
    
    it "doesn't send password back" do 
      @login_params[:password] = 'FROBNOZZ'
      do_create
      response.should_not have_text(/FROBNOZZ/i)
    end
  end
  
  describe "on signout" do
    def do_destroy
      get :destroy
    end
    it 'logs me out' do
      controller.should_receive(:logout_keeping_member_session!)
      do_destroy
    end
    
    it 'redirects to members login' do
      do_destroy
      response.should be_redirect
    end
  end
end