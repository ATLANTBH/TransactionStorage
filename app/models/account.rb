require 'utils'

class Account < ActiveRecord::Base

  include Utils

  STATE_ACTIVE = 0
  STATE_FROZEN = 1
  STATE_DELETED = 2
  
  TRANSACTION_GROUP_SEQUENCE = 'transaction_group_seq'
  
  has_many  :transactions
  
  # Delete account - not realy, just change state
  def delete_account()
    self.state = STATE_DELETED
    self.save
  end
  
  # Freeze account - fraud management
  def freeze_account()
    self.state = STATE_FROZEN
    self.save
  end

  # Unfreeze
  def unfreeze_account()
    self.state = STATE_ACTIVE
    self.save
  end
  
  # Get account history 
  def history(offset)
    count = Transaction.where('(tran_type = ? AND account_id = ?) OR (tran_type = ? AND to_id = ?)', Transaction::TYPE_P, self.id, Transaction::TYPE_T, self.id).count
    history = Transaction.where('(tran_type = ? AND account_id = ?) OR (tran_type = ? AND to_id = ?)', Transaction::TYPE_P, self.id, Transaction::TYPE_T, self.id).order('created_at DESC').offset(offset).limit(20)
    total = self.value
    return { :count => count, :history => history, :total => total }
  end
  
  # Get all transactions in specific group
  def get_group_info(link_id)
    self.transactions.where(:link_id => link_id)
  end
  

  # 
  #  Make payment
  #  
  # data:
  # [{
  #   source    : {
  #     name : 'Paypal',
  #     data : 'HFKLF97856OPYTWMX86FFKJF876'
  #   },
  #   orders : [
  #     {
  #       order : 1234,
  #       pieces : [
  #         { amount  :-120, account : 10, type : 'P' },
  #         { amount  :  80, account : 2, type : 'T' },
  #         { amount  :  15, account : 3, type : 'T' },
  #       ]
  #     },
  #     {
  #       order : 1235,
  #       pieces : [
  #         { amount  : 20, account : 1 }
  #       ]
  #     }
  #   ]
  # }]
  def make_payment(data, request_ip)
    check_data_for_payment(data)

    # Source 
    source = data[:source]
    src_model = nil
    if (source[:name] == 'Paypal')
      src_model = Source.find(Source::PAYPAL)
    elsif (source[:name] == 'Pikpay')
      src_model = Source.find(Source::PIKPAY)
    elsif (source[:name] == 'Virman')
      src_model = Source.find(Source::VIRMAN)
    elsif (source[:name] == 'Pycsell')
      src_model = Source.find(Source::PYCSELL)
    else
      raise "Banking sources '#{source[:name]}' not implemented!!!"
    end

    #create PAYMENT type transaction
    
    group_id = ActiveRecord::Base.sequence_next(TRANSACTION_GROUP_SEQUENCE)
    
    # create TRANSFER transactions
    data[:orders].each do |order|
      order[:pieces].each do |piece|
        # lock acc and make sum payment
        to_acc = Account.get_account(piece[:account])
        if (to_acc && piece[:type] != Transaction::TYPE_P)
          to_acc.value += BigDecimal.new(piece[:amount])
          to_acc.save!
        end
        
        tran_type = nil
        case piece[:type]
          when 'P' then tran_type = Transaction::TYPE_P
          when 'T' then tran_type = Transaction::TYPE_T
          #when 'A'  then tran_type = Transaction::TYPE_A
        else
          raise "Unknown payment type : #{order_model.payment_type} for piece: #{piece.inspect}"
        end
        
        transfer_tr = Transaction.new({ 
          :account => self,
          :tran_type => tran_type, 
          :amount => piece[:amount], 
          :to => to_acc,
          :order => order[:order],
          :ip => Account.ip2number(request_ip),          
          :link_id => group_id,
          :source_data => source[:data],
          :source => src_model
        })
        self.transactions << transfer_tr
        
      end
    end
    
    return { :status => :ok }
  end
  
  # Check if account have specific ammount 
  def check_amount_avaliability(amount_to_pay)
    return self.amount_stats() > amount_to_pay
  end
  
  #
  # Check for required params
  #
  # data:
  # [{
  #   source    : {
  #     name : 'Paypal',
  #     data : 'HFKLF97856OPYTWMX86FFKJF876'
  #   },
  #   orders : [
  #     {
  #       order : 1234,
  #       pieces : [
  #         { amount  :-120, account : 10, type : 'P' },
  #         { amount  :  80, account : 2, type : 'T' },
  #         { amount  :  15, account : 3, type : 'T' },
  #       ]
  #     },
  #     {
  #       order : 1235,
  #       pieces : [
  #         { amount  : 20, account : 1 }
  #       ]
  #     }
  #   ]
  # }]
  def check_data_for_payment(data)
    # Top level
    required_params([:source, :orders], data)
    
    # Source
    required_params([:name], data[:source])
    
    # order params
    data[:orders].each do |order| 
      required_params([:order, :pieces], order)
      
      # pieces
      order[:pieces].each do |piece|
        required_params([:amount, :account], piece)
      end
    end
    
  end
  
  def amount_stats
    return Transaction.amount_stats(self.id)
  end
  
  def self.amount_stats(account_id)
    return Transaction.amount_stats(account_id)
  end
  
  
  def self.ip2number(ip_string)
    octets = ip_string.split('.')
    if (octets.length != 4) 
      raise "Bad IP address #{ip_string}"
    end
      
    return (octets[0].to_i * 16777216) + (octets[1].to_i * 65536) + (octets[2].to_i * 256) + (octets[3].to_i)
  end  
  
  # Crate new account
  def self.create_account(user_id, creation_ip)
    if (Account.where(:user_id => user_id, :ip => ip2number(creation_ip)).length > 0) 
      raise "Accout for user #{user_id} already exists!!!"
    end
    
    account = Account.new({ :state => STATE_ACTIVE, :user_id => user_id, :last_transaction => Time.now, :ip => ip2number(creation_ip)  })
    account.save
    return account
  end
  
  # Get all acccounts
  def self.get_all_accounts(page)
    return Account.where(:state => STATE_ACTIVE).limit(15).offset(page)
  end
  
  # Get active account - lock row if needed. FROZEN or DISABLED accounts will raise error
  def self.get_active_account(id, lock = false)
    account =  Account.where(:id => id, :state => STATE_ACTIVE).lock(lock).first
    raise ErrorResponse.no_account(id) if account.nil?
    return account
  end
  
  # Get account - lock row if needed
  def self.get_account(id, lock = false)
    account =  Account.where(:id => id).lock(lock).first
    raise ErrorResponse.no_account(id) if account.nil?
    return account
  end  
  
end