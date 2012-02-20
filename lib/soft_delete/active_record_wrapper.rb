module SoftDelete

  def self.included(base)
    base.extend(ClassMethods)
  end  
  
  def delete
    self.update_attribute('deleted', true)
  end
  
  def undelete
    self.update_attribute('deleted', false)
  end
  
  def deleted?
     !!read_attribute(:deleted)
  end
  
  
  module ClassMethods
    def delete_all(conditions = nil)
      puts "-- DELETE ALL #{conditions}"
      self.update_all('deleted = true', conditions)
    end

    def delete(id)
      self.update(id, :deleted => true)
    end
  end
  
end