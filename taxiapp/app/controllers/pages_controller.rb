class PagesController < ApplicationController
  def home
    @user = User.new
  end

  def viaja
    @user = User.new
  end

  def conduce
    @user = User.new
  end

  def contacto
    @user = User.new
  end
end
