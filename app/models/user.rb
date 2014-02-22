class User < ActiveRecord::Base


  validates :first_name, presence: true
  validates :last_name, presence: true
  validates_uniqueness_of :email, presence: true
  validates :password, presence: true

end
