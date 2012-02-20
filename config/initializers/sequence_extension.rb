class ActiveRecord::Base 
  def self.sequence_next(name)
    self.connection.select_value("SELECT nextval('#{name}')")
  end
end