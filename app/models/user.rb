class User < ActiveRecord::Base
  
  has_many :turing_machines, :uniq => true
  has_many :likes, :through => :favorites, :uniq => true, :source => :turing_machine
  has_many :invitations, :uniq => true, :dependent => :destroy
  has_many :favorites, :uniq => true, :dependent => :destroy
  
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_format_of :name, :with => /^[a-zA-Z\d-]*$/
  validates_length_of :name, :in => 6..255

  validates_confirmation_of :password
  validates_presence_of :password_confirmation, :if => :hashed_password_changed?
  validates_length_of :password, :in => 6..255, :if => :hashed_password_changed?

  attr_accessible :name, :password, :password_confirmation
  attr_accessor :password

  def self.authenticate(name, password)
    user = self.find_by_name(name)
    if user
      expected_password = encrypted_password(password, user.salt)
      if user.hashed_password != expected_password
        user = nil
      end
    end
    user
  end
    
  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = self.class.encrypted_password(self.password, self.salt)
  end
  
  def add_invitations(copy=12)
    (1..copy).to_a.each do
      Invitation.create(
        :code => Invitation.generate_code,
        :user_id => id
      )
    end
  end
  
private
  
  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
  
  def self.encrypted_password(password, salt)
    string_to_hash = password + "wibble" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end

end
