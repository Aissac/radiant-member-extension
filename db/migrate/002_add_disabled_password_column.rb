class AddDisabledPasswordColumn < ActiveRecord::Migration
  def self.up
    add_column :members, :disabled_password, :string
  end
  
  def self.down
    remove_column :members, :disabled_password
  end
end
