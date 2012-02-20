require 'fraud_detection/transaction'

# Extend from APIController so only valid 
# (identified and validated) request will hit
# this controller.
#

class Api::AccountsController < Api::ApiController
  
  # For now we dont show all accounts!!!
  def index
    raise ErrorResponse.not_implemented
  end
  
  def create
    required_params([:user_id])
    
    render :response => Account.create_account(params[:user_id], request.remote_ip)
  end
  
  def update
    raise ErrorResponse.not_implemented
  end
  
  def show
    required_params([:id])
    
    render :response => Account.get_active_account(params[:id])
  end
  
  def stats
    required_params([:id])
    
    render :response => Account.amount_stats(params[:id])
  end
  
  def history
    required_params([:id])
    offset = params[:offset].blank? ? 0 : params[:offset].to_i
    
    account = Account.get_account(params[:id])
    render :response => account.history(offset)
  end
  
  def destroy
    required_params([:id])

    ActiveRecord::Base.transaction do
      account = Account.get_account(params[:id], true)
      account.delete_account()
    end
    
    render :response => { }
  end
  
  def freeze
    required_params([:id])

    ActiveRecord::Base.transaction do
      account = Account.get_active_account(params[:id], true)
      account.freeze_account()
    end
  
    render :response => { }
  end
  
  def unfreeze
    required_params([:id])

    ActiveRecord::Base.transaction do
      account = Account.get_account(params[:id], true)
      account.unfreeze_account()
    end
    
    render :response => { }
  end
  
  def group_info
    required_params([:id, :link_id])
    
    account = Account.get_account(params[:id])
    render :response => account.get_group_info(params[:link_id])
  end
  
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
  #         { amount  :   5, account : 4, type : 'A' }
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
  
  def payment
    required_params([:id, :_json])
    
    data = HashWithIndifferentAccess.new(JSON.parse(params[:_json]))
    
    ActiveRecord::Base.transaction do
      account = Account.get_account(params[:id])
      render :response => account.make_payment(data, request.remote_ip)
    end    
  end
  
  # TODO - transfer money from one account to other 
  # def transfer
  #   required_params([:id, :_json])
  #   
  #   data = HashWithIndifferentAccess.new(JSON.parse(params[:_json]))
  #   
  #   ActiveRecord::Base.transaction do
  #     account = Account.get_account(params[:id])
  #     render :response => account.make_transfer(data, request.remote_ip)
  #   end    
  # end
  
end