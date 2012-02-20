#
# We predefined some payment sources. More can be defined in seed file
#
class Source < ActiveRecord::Base
  PAYPAL = 1
  PIKPAY = 2
  VIRMAN = 3
  PYCSELL= 4
  
  has_many :transactions
end