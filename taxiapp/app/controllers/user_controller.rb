class UserController < ApplicationController
  
  def newclient
    @user =  User.new
  end
  
  def newdriver
    @user =  User.new
  end
  
  def create
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
                     plate:params[:user][:plate])
                     
    @user.save()
    redirect_to(:back)
  end
  
  def index
    @user = User.new
  end
  
  def login
    
    session[:current_user] = nil
    
    if !session[:current_user]
      
      user = User.find_by("email = ? AND passwd = ?",  params[:user][:email], params[:user][:passwd])
      session[:current_user] = user
      
      if session[:current_user]

        if user.role == "2"
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
