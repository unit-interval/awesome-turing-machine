class TuringMachine < ActiveRecord::Base
  
  belongs_to :user
  has_many :users, :through => :favorites, :uniq => true
  has_many :favorites, :dependent => :destroy
  
  validates_presence_of :name
  validates_length_of :name, :maximum => 255

  validates_length_of :description, :maximum => 1023

  validates_length_of :default_input, :maximum => 1023

  validates_length_of :definition, :maximum => 1023

  validate :welldefinedness # validates default_input and defitnition

  validates_uniqueness_of :short_url, :allow_blank => true
  validates_format_of :short_url, :with => /^[a-zA-Z\d-]*$/
  validates_length_of :short_url, :maximum => 255
  
  validates_numericality_of :users_count, :only_integer =>true, :greater_than_or_equal_to => 0
  
  attr_protected :users_count, :users
  
  def increase_users_count(probability=0.01)
    if rand() < probability
      self.users_count = self.users.count
    else
      self.users_count += 1
    end
    self.update_attributes({ :users_count => self.users_count }, :as => :favorite)
  end

  def decrease_users_count(probability=0.01)
    if self.users_count == 0 or rand() < probability
      self.users_count = self.users.count
    else
      self.users_count -= 1
    end
    self.update_attributes({ :users_count => self.users_count }, :as => :favorite)
  end

  def self.popular(n=10)
    find(:all, :order => "users_count desc", :limit => n)
  end
  
  def self.newest(n=10)
    find(:all, :order => "id desc", :limit => n)
  end
  
  def previous
    TuringMachine.find(:last, :conditions => ["id < ?", self.id]) || TuringMachine.find(:last)
  end
  
  def next
    TuringMachine.find(:first, :conditions => ["id > ?", self.id]) || TuringMachine.find(:first)
  end
  
  def self.random_id
    find(:first, :offset => rand(count)).id if count != 0
  end
  
private
  
  # this is ugly. any idea to improve? basically its verification the welldefinedness.
  
  def welldefinedness
    q = (48..57).to_a + (65..90).to_a + (97..122).to_a
    # 0..9, a..z, A..Z --> states
    b = 127
    # blank nonbreak space --> blank symbol
    g = (32..127).to_a
    # 32..126, blank --> tape symbols
    s = [76, 82, 78]
    # L, R, N --> shift
    default_input.each_byte do |c|
      return errors.add(:default_input, 'it contains blank or illegal symbols.') unless (g.member?(c) and c != b)
    end
    return errors.add(:definition, 'something wrong with the table of rules!'+definition.length.to_s) unless ((definition.length - 1) % 5 == 0) and (q.member?(definition.ord))
    definition[1..-1].scan(/...../).each do |d|
      return errors.add(:definition, 'something wrong with the table of rules0.') unless q.member?(d[0].ord)
      return errors.add(:definition, 'something wrong with the table of rules1.') unless g.member?(d[1].ord)
      return errors.add(:definition, 'something wrong with the table of rules2.') unless q.member?(d[2].ord)
      return errors.add(:definition, 'something wrong with the table of rules3.') unless g.member?(d[3].ord)
      return errors.add(:definition, 'something wrong with the table of rules4.') unless s.member?(d[4].ord)
    end
  end

end

