class OrderController < ApplicationController
  
  def client
    @order = Order.new
  end
  
  def driver
    @order = Order.new
  end
  
  def create
  end
  
  def new
  end
  
end
