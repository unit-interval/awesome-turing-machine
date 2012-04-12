class Invitation < ActiveRecord::Base
    
  belongs_to :user
    
  validates_uniqueness_of :code
  
  def self.generate_code(length = 16)
    begin
      charset = ('a'..'z').to_a + ('0'..'9').to_a
      code = (1..length).collect{charset[rand(charset.size)]}.join
    end while Invitation.find_by_code(code)
    code
  end
  
end
