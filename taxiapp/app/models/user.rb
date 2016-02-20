class User < ActiveRecord::Base
    has_many :order
    validates :email, presence: true
    validates :passwd, presence: true
    validates :first_name, presence: true
    validates :credit_card, presence: true
    validates :expiration_credit_card, presence: true
    validates :cvv, presence: true
end
