class Favorite < ActiveRecord::Base

  belongs_to :user
  belongs_to :turing_machine
  
  validates_presence_of :user_id, :turing_machine_id
  
end
