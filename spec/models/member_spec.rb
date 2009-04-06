require File.dirname(__FILE__) + '/../spec_helper'

describe Member do
  
  def valid_member_attributes
    {
      :name => 'name_test', 
      :company => 'company_test', 
      :email => 'email@example.com', 
      :password => 'pass_test', 
      :password_confirmation => 'pass_test',
    }
  end
  
  def create_member(options = {})
    @member = Member.new
    @member.attributes = valid_member_attributes.merge(options)
    @member.save
    @member
  end
      
  describe Member, "validations" do
    
    before do
      @member = Member.new
    end
    
    it "should be valid" do
      m = create_member
      m.should be_valid
    end
    
    ['email', 'name', 'company'].each do |required_attribute|
      it "requires #{required_attribute} attribute" do
        lambda do
          m = create_member(required_attribute.to_sym => nil)
          m.errors_on(required_attribute.to_sym).should_not be_nil
        end.should_not change(Member, :count)
      end
    end
      
    it "needs password confirmation" do
      lambda do
        m = create_member(:password => 'asdasd', :password_confirmation => 'dsadsa')
        m.errors_on(:password_confirmation).should_not be_nil
      end.should_not change(Member, :count)
    end
    
    ['Andre The Giant (7\'4", 520 lb.) -- has a posse', '1234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890'].each do |name_string|
      it "allows legitimate name #{name_string}" do
        lambda do
          m = create_member(:name => name_string)
          m.errors.on(:name).should be_nil
        end.should change(Member, :count).by(1)      
      end
    end
    
    ["tab\t", "newline\n"].each do |name_string|
      it "disallows illegitimate name #{name_string}" do
        lambda do
          m = create_member(:name => name_string)
          m.errors_on(:name).should_not be_nil
        end.should_not change(Member, :count)
      end  
    end 
    
    ['foo@bar.com', 'foo@newskool-tld.museum', 'foo@twoletter-tld.de', 'foo@nonexistant-tld.qq',
     'r@a.wk', '1234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890@gmail.com',
     'hello.-_there@funnychar.com', 'uucp%addr@gmail.com', 'hello+routing-str@gmail.com',
     'domain@can.haz.many.sub.doma.in', 'student.name@university.edu'
    ].each do |email_string|
      it "allows legitimate email #{email_string}" do
        lambda do
          m = create_member(:email => email_string)
          m.errors.on(:email).should be_nil
        end.should change(Member, :count).by(1)
      end
    end
    
    ['!!@nobadchars.com', 'foo@no-rep-dots..com', 'foo@badtld.xxx', 'foo@toolongtld.abcdefg',
     'Iñtërnâtiônàlizætiøn@hasnt.happened.to.email', 'need.domain.and.tld@de', "tab\t", "newline\n", 'r@.wk',
     # these are technically allowed but not seen in practice:
     'uucp!addr@gmail.com', 'semicolon;@gmail.com', 'quote"@gmail.com', 'tick\'@gmail.com', 'backtick`@gmail.com', 'space @gmail.com', 'bracket<@gmail.com', 'bracket>@gmail.com'
    ].each do |email_string|
      it "disallows illegitimate email #{email_string}" do
        lambda do
          m = create_member(:email => email_string)
          m.errors.on(:email).should_not be_nil
        end.should_not change(Member, :count)
      end
    end    
  end
  
  describe Member, "filters and sorting (members_paginate)" do

    %w{name email company}.each do |s|
      it "responds to named scope by_#{s}" do
        Member.respond_to?(:"by_#{s}").should be_true
      end

    end
    Member::SORT_COLUMNS.each do |i|
      it "sorts by known column #{i}" do
        Member.should_receive(:paginate).with(:page => 1, :per_page => 10, :order => "#{i} asc")
        Member.members_paginate(:sort_by => i, :sort_order => 'asc', :page => 1)
      end
    end
    
    it "does not sort by unknown column" do
      Member.should_receive(:paginate).with(:page => 1, :per_page => 10)
      Member.members_paginate(:sort_by => 'test', :sort_order => 'asc', :page => 1)
    end
    
    it "does not sort by unknown sort order attribute" do
      Member.should_receive(:paginate).with(:page => 1, :per_page => 10)
      Member.members_paginate(:sort_by => 'name', :sort_order => 'test', :page => 1)
    end
    
    Admin::MembersController::FILTER_COLUMNS.each do |i|
      it "filters by #{i}" do
        foo = mock("proxy")
        foo.should_receive(:paginate)
        Member.should_receive(:"by_#{i}").with('test').and_return(foo)
        Member.members_paginate(i => 'test')
      end
    end
    
    it "finds members grouped by company" do
      Member.should_receive(:find).with(:all, :group => 'company')
      Member.find_all_group_by_company
    end
  end

  describe Member, 'authentication' do
    
    before do
      @member = create_member
    end
      
    it 'authenticates user' do
      Member.authenticate('email@example.com', 'pass_test').should == @member
    end
    
    it "doesn't authenticate user with bad password" do
      Member.authenticate('email@example.com', 'invalid_password').should be_nil
    end
    
    it "doesn't authenticate inactive user" do
      Member.authenticate('test@email.com', '').should be_nil
    end
    
    it "updates the emailed_at field" do
      @member.email_new_password
      @member.emailed_at.should_not be_nil
    end
    
    it 'resets password' do
      @member.update_attributes(:password => 'new password', :password_confirmation => 'new password')
      Member.authenticate('email@example.com', 'new password').should == @member
    end

    it 'does not rehash password' do
      @member.update_attributes(:email => 'email2@example.com')
      Member.authenticate('email2@example.com', 'pass_test').should == @member
    end
    
    it 'sets remember token' do
      @member.remember_me
      @member.remember_token.should_not be_nil
      @member.remember_token_expires_at.should_not be_nil
    end
    
    it 'unsets remember token' do
      @member.remember_me
      @member.remember_token.should_not be_nil
      @member.forget_me
      @member.remember_token.should be_nil
    end
  end
  
  describe Member, "import from CSV" do
    
    before do
      @csv = open(File.dirname(__FILE__) + '/../fixtures/members.csv')
      Member.delete_all
      create_member(:name => 'Duplicate John', :company => 'ACME Inc.', :email => 'john@example.com')
      @imported_count, @duplicate_count, @not_valid = Member.import_members(@csv)
    end
    
    it "imports" do
      @imported_count.should == 1
    end
    
    it "does not import duplicate members" do
      @duplicate_count.should == 1
    end
    
    it "does not import invalid members" do
      @not_valid[0].should == ["Invalid George", "bad_email", "Microsoft", "Email is invalid"]
    end
  end
  
  describe Member, "update invalid members after CSV import" do
    
    before do
      params = [
        {:name => "Valid Jerry", :email => "jerry@email.com", :company => "MGM"},
        {:name => "Invalid George", :email => "bad_email", :company => "Microsoft"}]
      @imported_count, @not_valid = Member.update_invalid_members(params)
    end
    
    it "imports" do
      @imported_count.should == 1
    end
    
    it "does not import invalid members" do
      @not_valid[0].should == ["Invalid George", "bad_email", "Microsoft", "Email is invalid"]
    end
  end
  
  describe Member, "activate and deactivate" do
    
    before do
      create_member
      @m = Member.find(@member.id)
    end
    
    it "activates member by creating a new crypted password" do
      @m.crypted_password = nil
      @m.save
      @m.activate!
      @m.crypted_password.should_not be_nil
    end
    
    it "activates member by copying the disabled password to crypted password field" do
      @m.crypted_password = nil
      @m.disabled_password = 'abcdef'
      @m.save
      @m.activate!
      @m.crypted_password.should == 'abcdef'
    end
    
    it "deactivates member by copying the crypted password into disabled_password field" do
      disabled_password = @m.crypted_password
      @m.deactivate!
      @m.disabled_password.should == disabled_password
      @m.crypted_password.should == nil
    end
  end
end
