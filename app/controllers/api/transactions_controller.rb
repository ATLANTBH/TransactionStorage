class Api::TransactionsController < ApiController
  
  def status
    @response.set_document({ :status => :ok })
    render :json => @response
  end
end