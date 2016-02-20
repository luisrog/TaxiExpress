class PagesController < ApplicationController
  def home
    @order = Order.new
    @user = User.new
  end

  def viaja
    @order = Order.new
    @user = User.new
  end

  def conduce
    @order = Order.new
    @user = User.new
  end

  def contacto
    @order = Order.new
    @user = User.new
  end
end
