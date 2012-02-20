class Accounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.integer :user_id, :null => false
      t.decimal :value, :default => 0
      t.integer :state, :default => 0
      t.date    :last_transaction
      t.integer :ip, :limit => 8
      t.timestamps
    end
    
    add_index :accounts, [:user_id, :ip]
    
    execute('ALTER SEQUENCE accounts_id_seq START 10000')
    
  end

  def self.down
    drop_table  :accounts
  end
end
