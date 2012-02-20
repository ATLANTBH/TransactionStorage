class BaseObjectCtor
    
  def initialize(params) 
    if (params)
      params.each do |k, v|
        if (self.respond_to?(k))
          self.send("#{k.to_s}=", v)
        else
          raise "#{self.name} does not have attribute '#{k}' in action '#{params[:name]}'"
        end
      end
    end
  end
  
end