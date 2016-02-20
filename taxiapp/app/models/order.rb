class Order < ActiveRecord::Base
    belongs_to :user
    validates :address_origin, presence: true
    validates :address_destination, presence: true
    validates :time_estimated, presence: true
end
