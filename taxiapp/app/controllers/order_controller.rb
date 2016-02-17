class OrderController < ApplicationController
  
  def client
    @user = User.new
    @order = Order.new
    @orders = ActiveRecord::Base.connection.execute("SELECT * FROM orders o LEFT JOIN users u ON o.user_driver = u.id WHERE o.user_client = '#{session[:current_user]['id']}' AND o.state != 'Terminado' ORDER BY o.created_at ASC LIMIT 3")
  end
  
  def driver
    @user = User.new
    
    user = User.find(session[:current_user]['id'])
    
    if(user.state_driver == "L")
      order = ActiveRecord::Base.connection.execute("SELECT o.* FROM orders o WHERE o.state = 'Pendiente' ORDER BY o.id DESC")
    else
      order = ActiveRecord::Base.connection.execute("SELECT o.* FROM orders o LEFT JOIN users u ON o.user_driver = u.id WHERE o.user_driver = '#{session[:current_user]['id']}' AND o.state != 'Pendiente' AND u.state_driver = 'O'")
    end
    
    @order = Order.new
    order.each(:as => :hash) do |row, index|
      @order.id = row["id"]
      @order.address_origin = row["address_origin"]
      @order.address_destination = row["address_destination"]
      @order.reference = row["reference"]
      @order.time_estimated = row["time_estimated"]
      @order.state = row["state"]
    end
    
    @orders = ActiveRecord::Base.connection.execute("SELECT * FROM orders o LEFT JOIN users u ON o.user_driver = u.id WHERE o.user_driver = '#{session[:current_user]['id']}' AND o.state != 'Pendiente' ORDER BY o.created_at DESC LIMIT 3")
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
  
  ##Busca ordenes pendientes para mostralo en el chofer o mostrar la orden que confirmo
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
  
  ##Confirmacion de orden, iniciar y terminar la orden de acuerdo al estado
  def update
    
    @user = User.new
    @order = Order.find(params[:order][:id])
    
    if @order.state == "Pendiente"
    
      user = User.find(session[:current_user]['id'])
      user.state_driver = "O"
      user.save()
      
      @order.user_driver = session[:current_user]['id']
      @order.state = 'Confirmado'
      @order.save
    
    elsif @order.state == "Confirmado"
    
      @user = User.new
      @order = Order.find(params[:order][:id])
      @order.state = 'Iniciado'
      @order.start_time = Time.current.to_s
      @order.save
      
    elsif @order.state == "Iniciado"
    
      @user = User.new
      @order = Order.find(params[:order][:id])
      @order.state = 'Terminado'
      @order.end_time = Time.current.to_s
      @order.amount = ((@order.end_time.to_time.to_i - @order.start_time.to_time.to_i) * 0.01) + 5
      #@order.amount = 0
      @order.save
      
      user = User.find(session[:current_user]['id'])
      user.state_driver = "L"
      user.save()
    
    end
    
    redirect_to(:back)
  end
  
end
