class MembersDataset < Dataset::Base
  def load
    create_record :member, :bob, {:name => 'Bob Dylan', :email => 'bob@example.com', :company => 'ACME INC'}
  end
end