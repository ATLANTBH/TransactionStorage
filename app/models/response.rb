###################################
#
# Every response is represented via Response
#
# Sample response:
#
#  {
#    status   : { code : 0, message : 'ok' },
#    document : #some data serialized to JSON
# }
#

class Response
  
  attr_accessor :status
  attr_accessor :document
  
  def initialize()
    set_status(0, 'ok')
  end
  
  def set_status(error_code, error_message)
    self.status = {
      'code' => error_code,
      'message' => error_message
    }
  end
  
  def set_document(doc)
    self.document = doc
  end
  
  def error?
    self.status['code'] != 0
  end
  
  def error_code
    return self.status['code']
  end
  
  def error_message
    return self.status['message']
  end
  
  def self.from_obj(obj)
    r = Response.new
    r.status = obj['status']
    r.document = obj['document']
    return r
  end
end