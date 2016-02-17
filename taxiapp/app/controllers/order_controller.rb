class OrderController < ApplicationController
  
  def client
    @user = User.new
    @order = Order.new
    @orders = ActiveRecord::Base.connection.execute("SELECT * FROM orders o LEFT JOIN users u ON o.user_driver = u.id WHERE o.user_client = '#{session[:current_user]['id']}' AND o.state != 'Terminado' ORDER BY o.created_at DESC LIMIT 3")
  end
  
  def driver
    @user = User.new
    
    user = User.find(session[:current_user]['id'])
    
    if(user.state_driver == "L")
      @order = Order.find_by state: 'Pendiente'
    else
      @order = ActiveRecord::Base.connection.execute("SELECT * FROM orders o LEFT JOIN users u ON o.user_driver = u.id WHERE o.user_driver = '#{session[:current_user]['id']}' AND o.state = 'Confirmado' AND u.state_driver = 'O'")
    end
    
    @orders = ActiveRecord::Base.connection.execute("SELECT * FROM orders o LEFT JOIN users u ON o.user_driver = u.id WHERE o.user_driver = '#{session[:current_user]['id']}' AND o.state != 'Pendiente' ORDER BY o.created_at LIMIT 3")
  end
  
  def historialclient
    @user = User.new
    @orders = ActiveRecord::Base.connection.execute("SELECT * FROM orders o LEFT JOIN users u ON o.user_driver = u.id WHERE o.user_client = '#{session[:current_user]['id']}'")
    
    if(!@orders)
      @orders = Order.new   
    end 
  end
  
  def historialdriver
    @user = User.new
    @orders = ActiveRecord::Base.connection.execute("SELECT * FROM orders o LEFT JOIN users u ON o.user_driver = u.id WHERE o.user_driver = '#{session[:current_user]['id']}'")
    
    if(!@orders)
      @orders = Order.new   
    end 
  end
  
  def new
    @user = User.new
  end
  
  ##Busca ordenes pendientes para mostralo en el chofer
  def show
    @user = User.new
    @order = Order.find_by state: 'P'
     
    if(!@order)
      @order = Order.new   
    end 
  end
  
  ##Crea ordenes
  def create
    @user = User.new
    @order = Order.new(user_client:session[:current_user]['id'], 
                     address_origin:params[:order][:address_origin],
                     address_destination:params[:order][:address_destination],
                     reference:params[:order][:reference],
                     state:"Pendiente",
                     time_estimated:params[:order][:time_estimated],
                     payment_type:params[:order][:payment_type],
                     promotion_code:params[:order][:promotion_code])
                     
    @order.save()
    redirect_to(:back)
  end
  
  ##Confirmacion de orden
  def update
    @user = User.new
    @order = Order.find(params[:order][:id])
    @order.user_driver = session[:current_user]['id']
    @order.state = 'Confirmado'
    @order.save
    
    user = User.find(session[:current_user]['id'])
    user.state_driver = "O"
    user.save()
    
    redirect_to(:back)
  end
  
  ##inicio de carrera
  def updateStart
    @user = User.new
    @order = Order.find(params[:order][:id])
    @order.start_time = Time.current.to_s
    @order.save
    redirect_to(:back)
  end
  
  ##FIn y calculo de cobro de carrear
  def updateEnd
    @user = User.new
    @order = Order.find(params[:order][:id])
    @order.end_time = Time.current.to_s
    @order.ammount = ((@order.end_time - @order.start_time) * 0.01)
    @order.save
    
    user = User.find(session[:current_user]['id'])
    user.state_driver = "L"
    user.save()
    
    redirect_to(:back)
  end
  
end
