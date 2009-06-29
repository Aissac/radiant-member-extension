class MembersDataset < Dataset::Base
  def load    
    create_record :member, :bob, {:name => 'Bob Dylan', :email => 'bob@example.com', :crypted_password => "39884ac9d524e104569ca9ae76ed40ca84d2ab1e", :salt => "7a69427746c1e10127740fbb92c572bf46237174", :company => 'ACME INC'}
  end
end