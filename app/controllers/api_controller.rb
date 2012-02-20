##########################################################
#
# Any API Controller must extend from this controller.
#
# Main responsibility is to authenticate API caller.
#
# Identification is done via hashing secret key and
# request params. Hash is generated:
#
# 1. Sort all params  
# 2. Append all aprams and values [except :hash]
# 3. Append secret key
# 4. Make SHA256 hash
# 5. If hash is different discard request
#
# NOTE: Secret key must not be send!!!
#
require 'utils'
require 'config/configuration'
require 'digest/sha2'

class ApiController < ActionController::Base
  include Utils  
  
  # If request is older than 15 sec, discard request
  ALLOWED_TS_DIFF = 15
  
  protect_from_forgery
  
  # Check for correct hash
  before_filter :check_access
  
  # Generic error handler - if something gone wrong - render error response
  rescue_from StandardError do |error|
    Rails.logger.error("#{error} : #{error.backtrace.join("\n")}")
    if (error.is_a? ErrorResponse)
      render :json => error
    else
      render :json => ErrorResponse.internal_error(error)
    end
  end
  
  #
  # Extend Rails with ':response' so we can render our document domain model, e.g.
  #
  #  render :response => Model.find(0)
  #  
  #  Will render document in JSON :
  #
  #  status   : { code:0, message:'ok' },
  #  document : ':response' render Model serialized as json 
  #
  ActionController.add_renderer :response do |document, options|
    r = Response.new
    r.set_document(document)
  
    self.content_type ||= Mime::JSON
    self.response_body = r.to_json
  end  


  # Check for hash or render 
  def check_access
    @response = Response.new
    
    check_hash()
    
    if @response.error?
     access_denied
     return
    end
  end


private
  def check_hash()
    user_hash = params[:hash]
    user_ts = params[:ts]
    
    if (user_hash.blank?)
      @response = ErrorResponse.missing_hash
      return
    end
    
    if (user_ts.blank?)
      @response = ErrorResponse.missing_ts
      return
    end
    
    secret = Config::Configuration.get(:transaction_engine, :secret)
    params_string = params_to_url(params, {'hash' => true, 'action' => true, 'controller' => true, 'id' => true })
    string_to_hash = params_string + secret
    sha = Digest::SHA2.new << string_to_hash
    hash = sha.to_s
    
    time_diff = Time.now.to_i - params[:ts].to_i
    
    if ( time_diff < 0 || time_diff > ALLOWED_TS_DIFF)
      @response = ErrorResponse.invalid_ts
    end
    
    if (hash != params[:hash])
       @response = ErrorResponse.invalid_hash
       return
    end
  end
  
  def access_denied
    render :json => @response
  end

  
end
