module Utils
  
  def required_params(required, data = nil)
    data ||= params
    required.each do |r_param|
      unless (data.has_key?(r_param))
        raise ErrorResponse.missing_param(r_param)
      end
    end
  end  
  
  def parse_parent_params(param_string)
    param_string.strip!
    return Rack::Utils.parse_nested_query(CGI.unescape(param_string))
  end
  
  def params_to_url(params, except = {})
    url_params = []
    params_array = params.sort
    params_array.each do |param|
      unless (except.has_key?(param[0]))
        url_params << "#{param[0]}=#{CGI.escape(param[1].to_s)}"
      end
    end
    
    return url_params.join('&')
  end
    
  def split_nil(string_ar, separator)
    return  string_ar.nil? ? [] : string_ar.split(separator)
  end
  
  def camel_to_sentence(str)
    str.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1 \2').
    gsub(/([a-z\d])([A-Z])/,'\1 \2')
  end
  
  def safe_to_json(obj, options = nil)
     obj.to_json(options).gsub('>', '&gt;').gsub('<', '&lt;')
  end
  
end


# Fix to_json for Struct
class Struct
  def as_json(options = nil) 
    Hash[members.zip(values)]
  end
end