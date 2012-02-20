class Transactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      t.references  :account,  :null => false

      t.string      :tran_type, :limit => 1, :null => false
      
      t.decimal     :amount,    :default => 0, :null => false
      t.integer     :to_id
      t.integer     :order
      
      t.integer     :link_id
      
      # source
      t.string      :source_data
      t.references  :source
      
      # 
      t.integer     :ip,  :limit => 8
      
      t.timestamps
    end
    
    #add_index :transactions, [:account_id, :to_id, :order, :link_id]
    
    create_table  :sources do |t|
      t.string      :name
      t.string      :description
      t.timestamps
    end
    
     execute('CREATE SEQUENCE transaction_group_seq START 10000;')
  end

  def self.down
    execute('DROP SEQUENCE transaction_group_seq;')
    drop_table  :transactions
    drop_table  :sources
  end
end
