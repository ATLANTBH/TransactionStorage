###########################################
#
# Domain response for all errors.
#
# Raise this exception and api_controller
# will render it as Response object
# with specific error_code and error_message
#

class ErrorResponse < StandardError
  
  SUCCESS       = 0
  MISSING_HASH  = 1
  MISSING_TS    = 2
  INVALID_HASH  = 3
  INVALID_TS    = 4
  INVALID_ROUTE = 5
  INTERNAL_ERROR = 6
  NOT_IMPLEMENTED = 7
  MISSING_PARAM = 8
  NO_ACCOUNT = 9
  FRAUD_NOTIFICATION = 10
  NEGATIVE_BALANS = 11
  
  attr_accessor :status
  
  
  def initialize(error_code, error_message)
    self.status = {
      'code' => error_code,
      'message' => error_message
    }
  end
  
  def self.missing_hash
    Rails.logger.info('[ERROR_RESPONSE] Missing hash')
    return ErrorResponse.new(MISSING_HASH, "Missing hash")
  end
  
  def self.missing_ts
    Rails.logger.info('[ERROR_RESPONSE] Missing timestamp')
    return ErrorResponse.new(MISSING_TS, "Missing timestamp")
  end
  
  def self.invalid_hash
    Rails.logger.info('[ERROR_RESPONSE] Invalid hash')
    return ErrorResponse.new(INVALID_HASH, "Invalid hash")
  end
  
  def self.invalid_ts
    Rails.logger.info('[ERROR_RESPONSE] Invalid timestamp')
    return ErrorResponse.new(INVALID_TS, "Invalid timestamp")
  end
  
  def self.internal_error(error)
    Rails.logger.info("[ERROR_RESPONSE] Internal error : #{error}")
    return ErrorResponse.new(INTERNAL_ERROR, "Internal error : #{error}")
  end
  
  def self.not_implemented
    Rails.logger.info('[ERROR_RESPONSE] Function not implemented')
    return ErrorResponse.new(NOT_IMPLEMENTED, "Function not implemented")
  end
  
  def self.missing_param(param)
    Rails.logger.info("[ERROR_RESPONSE] Missing param '#{param}'")
    return ErrorResponse.new(MISSING_PARAM, "Missing param '#{param}'")
  end
  
  def self.no_account(id)
    Rails.logger.info("[ERROR_RESPONSE] Account '#{id}' not found or not active")
    return ErrorResponse.new(NO_ACCOUNT, "Account '#{id}' not found or not active")
  end
  
  def self.fraud_error(account_id, reason)
    Rails.logger.info("[ERROR_RESPONSE] Account '#{account_id}' frozen by Fraud detection system. Reason : #{reason}")
    return ErrorResponse.new(FRAUD_NOTIFICATION, "Account '#{account_id}' frozen by Fraud detection system. Reason : #{reason}")
  end
  
  def self.negative_balance(account_id)
    Rails.logger.info("[ERROR_RESPONSE] Account '#{account_id}' cannot have negative balance")
    return ErrorResponse.new(NEGATIVE_BALANS, "Account '#{account_id}' cannot have negative balance")
  end
  
  def error?
    true
  end
  
  
end