#
# Transaction model in DB
#
# Example of payment:
#
#  - Black PC Mouse  - 15 EUR
#  - Shiping via DHL - 15 EUR
#
# Will insert following transactions:
#
#     TO    TYPE         AMOUNT
#     1     P(PAYMENT)   -30 
#     2     T(TRANSFER)   13 EUR   # Transfer to 3rd party (real cost is 13 EUR)
#     3     T(TRANSFER)   15 EUR   # Transfer to DHL (real cost is 15 EUR)
#     3     T              2 EUR   # Transfer to me 2EUR (provision)
#
class Transaction < ActiveRecord::Base
  
  TYPE_P = 'P' # Payment
  TYPE_T = 'T' # Transfer
  
  belongs_to  :account
  
  belongs_to  :to,  :class_name => 'Account'

  belongs_to  :source
  
  def self.amount_stats(account_id)
    return Transaction.where('tran_type = ? AND to_id = ?', TYPE_T, account_id).sum(:amount)
  end
  
end