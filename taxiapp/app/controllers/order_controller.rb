class OrderController < ApplicationController
  
  def admin
     @user = User.new
     @order = Order.new
  end
  
  def reportclient
     @user = User.new
     @order = Order.new
     @users = ActiveRecord::Base.connection.execute("SELECT * 
                                                        FROM users o 
                                                        ORDER BY o.created_at ASC")
  end
  
  def reportorder
     @user = User.new
     @order = Order.new
     @orders = ActiveRecord::Base.connection.execute("SELECT o.*, d.*, c.*, o.id AS orderid 
                                                        FROM orders o 
                                                        LEFT JOIN users d ON o.user_driver = d.id
                                                        INNER JOIN users c ON o.user_client = c.id
                                                        ORDER BY o.created_at ASC")
  end
  
  def client
    @user = User.new
    @order = Order.new
    @orders = ActiveRecord::Base.connection.execute("SELECT o.*, u.*, o.id AS orderid
                                                        FROM orders o 
                                                        LEFT JOIN users u ON o.user_client = u.id 
                                                        WHERE o.user_client = '#{session[:current_user]['id']}' AND o.state != 'Terminado' 
                                                        ORDER BY o.created_at 
                                                        ASC LIMIT 3")
  end
  
  def driver
    @user = User.new
    
    user = User.find(session[:current_user]['id'])
    
    if(user.state_driver == "Libre")
      order = ActiveRecord::Base.connection.execute("SELECT o.*, o.id AS orderid
                                                        FROM orders o 
                                                        WHERE o.state = 'Pendiente' 
                                                        ORDER BY o.id DESC")
    else
      order = ActiveRecord::Base.connection.execute("SELECT o.*, u.*, o.id AS orderid
                                                        FROM orders o 
                                                        LEFT JOIN users u ON o.user_driver = u.id 
                                                        WHERE o.user_driver = '#{session[:current_user]['id']}' AND o.state != 'Pendiente' AND u.state_driver = 'Ocupado'")
    end
    
    @order = Order.new
    order.each(:as => :hash) do |row, index|
      @order.id = row["orderid"]
      @order.address_origin = row["address_origin"]
      @order.address_destination = row["address_destination"]
      @order.reference = row["reference"]
      @order.time_estimated = row["time_estimated"]
      @order.state = row["state"]
      @order.payment_type = row["payment_type"]
    end
    
    @orders = ActiveRecord::Base.connection.execute("SELECT * 
                                                        FROM orders o 
                                                        LEFT JOIN users u ON o.user_driver = u.id 
                                                        WHERE o.user_driver = '#{session[:current_user]['id']}' AND o.state != 'Pendiente' 
                                                        ORDER BY o.created_at DESC 
                                                        LIMIT 1")
  end
  
  def historialclient
    @order = Order.new
    @user = User.new
    @orders = ActiveRecord::Base.connection.execute("SELECT * 
                                                        FROM orders o 
                                                        LEFT JOIN users u ON o.user_driver = u.id 
                                                        WHERE o.user_client = '#{session[:current_user]['id']}'")
    
    if(!@orders)
      @orders = Order.new   
    end 
  end
  
  def historialdriver
    @order = Order.new
    @user = User.new
    @orders = ActiveRecord::Base.connection.execute("SELECT * 
                                                        FROM orders o 
                                                        LEFT JOIN users u ON o.user_driver = u.id 
                                                        WHERE o.user_driver = '#{session[:current_user]['id']}'")
    
    if(!@orders)
      @orders = Order.new   
    end 
  end
  
  def orderall
    @order = Order.new
    orders = ActiveRecord::Base.connection.execute("SELECT * 
                                                        FROM orders o 
                                                        LEFT JOIN users u ON o.user_driver = u.id 
                                                        WHERE o.user_client = '#{session[:current_user]['id']}' AND o.state != 'Terminado' 
                                                        ORDER BY o.created_at 
                                                        ASC LIMIT 3")
    return orders
  end
  
  def new
    @user = User.new
    @order = Order.new
  end
  
  ##Busca ordenes pendientes para mostralo en el chofer o mostrar la orden que confirmo
  def show
    @user = User.new
    @order = Order.find_by state: 'Pendiente'
     
    if(!@order)
      @order = Order.new   
    end 
  end
  
  ##Crea ordenes
  def create
    @user = User.new
    @order = Order.new
    @orders = orderall
    
    if params[:order][:address_origin] != ""
      if params[:order][:address_destination] != ""
        if params[:order][:time_estimated] != ""
    
          @order = Order.new(user_client:session[:current_user]['id'], 
                           address_origin:params[:order][:address_origin],
                           address_destination:params[:order][:address_destination],
                           reference:params[:order][:reference],
                           state:"Pendiente",
                           time_estimated:params[:order][:time_estimated],
                           payment_type:params[:order][:payment_type],
                           promotion_code:params[:order][:promotion_code])
                           
          if @order.save()
            @alertType = "success"
            @alertMessage = "Su pedido sera confirmado dentro de poco, sea paciente, gracias!."
            
            @orders = ActiveRecord::Base.connection.execute("SELECT * 
                                                        FROM orders o 
                                                        LEFT JOIN users u ON o.user_client = u.id 
                                                        WHERE o.user_client = '#{session[:current_user]['id']}' AND o.state != 'Terminado' 
                                                        ORDER BY o.created_at 
                                                        ASC LIMIT 3")
                                                        
            @order = Order.new
            
          end  
          
        elsif
          @alertType = "danger"
          @alertMessage = "Por favor el punto de encuentro, origen."
        end
        
      elsif
        @alertType = "danger"
        @alertMessage = "Por favor ingrese el lugar de destino."
      end
    
    elsif
      @alertType = "danger"
      @alertMessage = "Por favor ingrese el tiempo estimado de llegaba del taxi."
    end
    
    render :action => "client"
  end
  
  ##Confirmacion de orden, iniciar y terminar la orden de acuerdo al estado
  def update
    
    @user = User.new
    @order = Order.find(params[:order][:id])
    
    if @order.state == "Pendiente"
    
      user = User.find(session[:current_user]['id'])
      user.state_driver = "Ocupado"
      user.save()
      
      @order.user_driver = session[:current_user]['id']
      @order.state = 'Confirmado'
      @order.save
    
    elsif @order.state == "Confirmado"
    
      @order.state = 'Iniciado'
      @order.start_time = Time.current.to_s
      @order.save
      
    elsif @order.state == "Iniciado"
    
      @order.state = 'Terminado'
      @order.end_time = Time.current.to_s
      @order.amount = ((@order.end_time.to_time.to_i - @order.start_time.to_time.to_i) * 0.01) + 5
      #@order.amount = 0
      @order.save
      
      user = User.find(session[:current_user]['id'])
      user.state_driver = "Libre"
      user.save()
    
    end
    
    redirect_to("/order/driver")
  end
  
  def openorder
    @order = Order.new
  end
  
  def changecli
    @order = Order.new
  end
  
  def cancelcli
    @order = Order.new
  end
  
  def canceldri
    @order = Order.new
  end
  
  def edituseradmin
    @order = Order.new
    @user = User.new
    
    if params[:user][:first_name] != ""
      if params[:user][:credit_card] != ""
        if params[:user][:expiration_credit_card] != ""
          if params[:user][:cvv] != ""

            @user = User.find(params[:user][:id])
            @user.first_name = params[:user][:first_name]
            @user.last_name = params[:user][:last_name]
            @user.phone = params[:user][:phone]
            @user.credit_card = params[:user][:credit_card]
            @user.expiration_credit_card = params[:user][:expiration_credit_card]
            @user.cvv = params[:user][:cvv]
            @user.license = params[:user][:license]
            @user.state_driver = params[:user][:state_driver]
                             
            if @user.save()
              redirect_to(:back)
            end
            
          elsif
            @alertType = "danger"
            @alertMessage = "Por favor ingrese el codigo secreto de su tardejeta de credito."
          end
            
        elsif
          @alertType = "danger"
          @alertMessage = "Por favor ingrese la fecha de caducidad de la tardejeta de credito."
        end
          
      elsif
        @alertType = "danger"
        @alertMessage = "Por favor ingrese el numero de su tarjeta."
      end
        
    elsif
      @alertType = "danger"
      @alertMessage = "Por favor ingrese sus nombres."
    end
  end
  
  def deluseradmin
    @order = Order.new
    @user = User.new
    
    @user = User.find(params[:user][:id])
    @user.state_driver = "Anulado"
                             
    if @user.save()
      redirect_to(:back)
    end
  end
  
  def editorderadmin
    @order = Order.new
    @user = User.new
    
    if params[:order][:address_origin] != ""
      if params[:order][:address_destination] != ""
        if params[:order][:state] != ""

          @order = Order.find(params[:order][:id])
          @order.address_origin = params[:order][:address_origin]
          @order.address_destination = params[:order][:address_destination]
          @order.state = params[:order][:state]
          @order.reference = params[:order][:reference]
                           
          if @order.save()
            redirect_to(:back)
          end
          
        elsif
          @alertType = "danger"
          @alertMessage = "Por favor ingrese el el estado de la orden."
          end
      elsif
        @alertType = "danger"
        @alertMessage = "Por favor ingrese el lugar de destino."
      end
    elsif
      @alertType = "danger"
      @alertMessage = "Por favor ingrese el punto de encuentro."
    end
  end
  
  def delorderadmin
    @order = Order.new
    @user = User.new
    
    @order = Order.find(params[:order][:id])
    @order.state = "Anulado"
                             
    if @order.save()
      redirect_to(:back)
    end
  end
  
  def editordercli
    @order = Order.new
    @user = User.new
    
    if params[:order][:address_origin] != ""
      if params[:order][:address_destination] != ""
        if params[:order][:time_estimated] != ""
          if params[:order][:payment_type] != ""

            @order = Order.find(params[:order][:id])
            
            if @order.state == "Pendiente"  
            
              @order.address_origin = params[:order][:address_origin]
              @order.address_destination = params[:order][:address_destination]
              @order.time_estimated = params[:order][:time_estimated]
              @order.reference = params[:order][:reference]
              @order.payment_type = params[:order][:payment_type]
                               
              if @order.save()
                
              end
              
            else
              @alertType = "warning"
              @alertMessage = "El pedido ya fue confirmado por uno de nuestros choferes, para modificar la orden comuniquese con nosotros, gracias."
            end
            
          elsif
            @alertType = "danger"
            @alertMessage = "Por favor ingrese la forma de pago."
          end
        elsif
          @alertType = "danger"
          @alertMessage = "Por favor ingrese el tiempo estimado."
        end
      elsif
        @alertType = "danger"
        @alertMessage = "Por favor ingrese el lugar de destino."
      end
    elsif
      @alertType = "danger"
      @alertMessage = "Por favor ingrese el punto de encuentro."
    end
    
    redirect_to(:back)
  end
  
  def delordercli
    @order = Order.new
    @user = User.new
    
    @order = Order.find(params[:order][:id])
    
    if @order.state == "Pendiente"
      @order.state = "Anulado"
                               
      if @order.save()
        
      end
    else
      @alertType = "warning"
      @alertMessage = "El pedido ya fue confirmado por uno de nuestros choferes, para cancelar la orden comuniquese con nosotros, gracias."
    end
    
    redirect_to(:back)
  end
  
  def delorderdri
    @order = Order.new
    @user = User.new
    
    @order = Order.find(params[:order][:id])
    
    if @order.state == "Pendiente"
      
      @user = User.find(session[:current_user]['id'])
      
      if @user.state_driver == "Libre"
      
        order = ActiveRecord::Base.connection.execute("SELECT o.* 
                                                          FROM orders o 
                                                          WHERE o.id = (SELECT id FROM orders WHERE state = 'Pendiente' AND id > #{params[:order][:id]} LIMIT 1)
                                                          ORDER BY o.id DESC")
                                                          
        @order = Order.new
        order.each(:as => :hash) do |row, index|
          @order.id = row["id"]
          @order.address_origin = row["address_origin"]
          @order.address_destination = row["address_destination"]
          @order.reference = row["reference"]
          @order.time_estimated = row["time_estimated"]
          @order.state = row["state"]
        end
        
        if @order.id == nil
          order = ActiveRecord::Base.connection.execute("SELECT o.* 
                                                        FROM orders o 
                                                        WHERE o.state = 'Pendiente' 
                                                        ORDER BY o.id DESC")
                                                        
          @order = Order.new
          order.each(:as => :hash) do |row, index|
            @order.id = row["id"]
            @order.address_origin = row["address_origin"]
            @order.address_destination = row["address_destination"]
            @order.reference = row["reference"]
            @order.time_estimated = row["time_estimated"]
            @order.state = row["state"]
          end
        end
        
        @orders = ActiveRecord::Base.connection.execute("SELECT * 
                                                            FROM orders o 
                                                            LEFT JOIN users u ON o.user_driver = u.id 
                                                            WHERE o.user_driver = '#{session[:current_user]['id']}' AND o.state != 'Pendiente' 
                                                            ORDER BY o.created_at DESC 
                                                            LIMIT 1")
                                                            
        render :action => "driver"
                                                          
      else
        @alertType = "warning"
        @alertMessage = "Tu estado esta ocupado, no puedes pasar el pedido, si fuera necesario comunicate con nosotros 998544125."
      end
                               
      
    else
      @alertType = "warning"
      @alertMessage = "El pedido fue confirmado, no puedes pasar el pedido, si fuera necesario comunicate con nosotros 998544125."
    end
  end
  
end
