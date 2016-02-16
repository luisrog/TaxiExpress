class OrderController < ApplicationController
  
  def client
    @order = Order.new
    @orders = ActiveRecord::Base.connection.execute("SELECT * FROM orders o INNER JOIN users u ON o.user_driver = u.id WHERE o.user_client = '#{session[:current_user]['id']}'")
  end
  
  def driver
    @order = Order.find_by state: 'P'
  end
  
  def new
  end
  
  def show
    @order = Order.find_by state: 'P'
     
    if(!@order)
      @order = Order.new   
    end 
  end
  
  def create
    @order = Order.new(user_client:session[:current_user]['id'], 
                     address_origin:params[:order][:address_origin],
                     address_destination:params[:order][:address_destination],
                     reference:params[:order][:reference],
                     state:"P",
                     time_estimated:params[:order][:time_estimated],
                     payment_type:params[:order][:payment_type],
                     promotion_code:params[:order][:promotion_code])
                     
    @order.save()
    redirect_to(:back)
  end
  
  def edit
  end
  
  def update
    @order = Order.find(params[:order][:id])
    @order.user_driver = session[:current_user]['id']
    @order.state = 'C'
    @order.save
    redirect_to(:back)
  end
  
  def updateConfirm
    #metodo de update de arriba
  end
  
  def updateStart
    @order = Order.find(params[:order][:id])
    @order.start_time = Time.current.to_s
    @order.save
    redirect_to(:back)
  end
  
  def updateEnd
    @order = Order.find(params[:order][:id])
    @order.end_time = Time.current.to_s
    @order.ammount = ((Time.current.to_s - @order.start_time) * 0.01)
    @order.save
    redirect_to(:back)
  end
  
end
