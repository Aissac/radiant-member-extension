class CreateMembers < ActiveRecord::Migration
  def self.up
    create_table :members do |t|
      t.column :name,                 :string
      t.column :email,                :string
      t.column :company,              :string
      t.column :crypted_password,     :string
      t.column :salt,                 :string 
      t.column :activation_code,      :string
      t.column :emailed_at,           :datetime
      t.timestamps
    end
  end

  def self.down
    drop_table :members
  end
end
