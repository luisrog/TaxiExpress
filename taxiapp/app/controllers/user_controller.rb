class UserController < ApplicationController
  
  def newclient
    @order = Order.new
    @user =  User.new
  end
  
  def newdriver
    @order = Order.new
    @user =  User.new
  end
  
  def create
    
    @order = Order.new
    @user = User.new
    
    if params[:user][:email] != ""
      if params[:user][:passwd] != ""
        if params[:user][:first_name] != ""
          if params[:user][:credit_card] != ""
            if params[:user][:expiration_credit_card] != ""
              if params[:user][:cvv] != ""
              
                @user = User.new(email:params[:user][:email], 
                               passwd:params[:user][:passwd],
                               first_name:params[:user][:first_name],
                               last_name:params[:user][:last_name],
                               role:params[:user][:role],
                               phone:params[:user][:phone],
                               credit_card:params[:user][:credit_card],
                               expiration_credit_card:params[:user][:expiration_credit_card],
                               cvv:params[:user][:cvv],
                               license:params[:user][:license],
                               soat:params[:user][:soat],
                               brand:params[:user][:brand],
                               modele:params[:user][:modele],
                               plate:params[:user][:plate],
                               state_driver:"Libre")
                               
                if @user.save()
                  @alertType = ""
                  @alertMessage = ""
                  
                  login()
                end 
                
              elsif
                @alertType = "danger"
                @alertMessage = "Por favor ingrese el codigo secreto de su tardejeta de credito."
                if params[:user][:role] == 2 then render :action => "newclient" else render :action => "newdriver" end
              end
                
            elsif
              @alertType = "danger"
              @alertMessage = "Por favor ingrese la fecha de caducidad de la tardejeta de credito."
              if params[:user][:role] == 2 then render :action => "newclient" else render :action => "newdriver" end
            end
              
          elsif
            @alertType = "danger"
            @alertMessage = "Por favor ingrese el numero de su tarjeta."
            if params[:user][:role] == 2 then render :action => "newclient" else render :action => "newdriver" end
          end
            
        elsif
          @alertType = "danger"
          @alertMessage = "Por favor ingrese sus nombres."
          if params[:user][:role] == 2 then render :action => "newclient" else render :action => "newdriver" end
        end
        
      elsif
        @alertType = "danger"
        @alertMessage = "Por favor ingrese una clave para su cuenta."
        if params[:user][:role] == 2 then render :action => "newclient" else render :action => "newdriver" end
      end
    
    elsif
      @alertType = "danger"
      @alertMessage = "Por favor ingrese un email valido."
      if params[:user][:role] == 2 then render :action => "newclient" else render :action => "newdriver" end
    end
    
  end
  
  def editclient
    @order = Order.new
    @user = User.find(session[:current_user]['id'])
  end
  
  def editdriver
    @order = Order.new
    @user = User.find(session[:current_user]['id'])
  end
  
  def update
    
    @order = Order.new
    @user = User.new
    
    if params[:user][:email] != ""
      if params[:user][:passwd] != ""
        if params[:user][:first_name] != ""
          if params[:user][:credit_card] != ""
            if params[:user][:expiration_credit_card] != ""
              if params[:user][:cvv] != ""
    
                @user = User.find(session[:current_user]['id'])
                @user.email = params[:user][:email]
                @user.passwd = params[:user][:passwd]
                @user.first_name = params[:user][:first_name]
                @user.last_name = params[:user][:last_name]
                @user.phone = params[:user][:phone]
                @user.credit_card = params[:user][:credit_card]
                @user.expiration_credit_card = params[:user][:expiration_credit_card]
                @user.cvv = params[:user][:cvv]
                @user.license = params[:user][:license]
                @user.soat = params[:user][:soat]
                @user.brand = params[:user][:brand]
                @user.modele = params[:user][:modele]
                @user.plate = params[:user][:plate]
                                 
                if @user.save()
                  @alertType = "success"
                  @alertMessage = "Se modificaron correctamente sus datos."
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
        
      elsif
        @alertType = "danger"
        @alertMessage = "Por favor ingrese una clave para su cuenta."
      end
    
    elsif
      @alertType = "danger"
      @alertMessage = "Por favor ingrese un email valido."
    end
    
    if params[:user][:role] == 3 then render :action => "editdriver" else render :action => "editclient" end
    
  end
  
  def show
    @user = User.new
    @order = Order.new
  end
  
  def index
    @user = User.new
    @order = Order.new
  end
  
  def login
    
    @order = Order.new
    @user = User.new
    
    session[:current_user] = nil
    
    if !session[:current_user]
      
      user = User.find_by("email = ? AND passwd = ? AND state_driver != ? ",  params[:user][:email], params[:user][:passwd], "Anulado")
      session[:current_user] = user
      
      if session[:current_user]
        if user.role == "1"
           redirect_to order_admin_url
        elsif user.role == "2"
           redirect_to order_client_url
        elsif user.role == "3"
           redirect_to order_driver_url
        else
          redirect_to root_url
        end
      
      else
        redirect_to root_url
      end
      
    else
      redirect_to root_url
    end
  end

  def logout
    session[:current_user] = nil
    redirect_to root_url
  end

end
