class CreditCard
  include Validatable
  
  attr_accessor :token
  
  attr_accessor :cvv
  validates_presence_of :cvv
  
  attr_accessor :number
  before_validation{ self.number.gsub!(/\D/,'') }
  validates_presence_of :number
  validates_length_of   :number, :minimum => 12
  validates_each        :number, :logic => lambda { errors.add(:number, "Card number is not valid") unless valid_checksum? }
  
  attr_accessor :expiration_month
  attr_accessor :expiration_year
  validates_presence_of :expiration_month
  validates_presence_of :expiration_year
  validates_length_of   :expiration_year, :is => 4
  validates_each        :expiration_month, :expiration_year, :logic => lambda{ 
    (errors.add(:expiration_month, "Card is expired") && errors.add(:expiration_year, "Card is expired")) if expired?
  }
  
  def initialize(*args)
    if attrs = args.first
      attrs.stringify_keys!
      attrs.assert_valid_keys("token","cvv","number","expiration_month","expiration_year")
      attrs.each_pair do |k,v|
        send((k + "=").to_sym,v)
      end
    end
  end
  
  def to_hash
    hash = Hash[:number => number,
                :cvv => cvv,
                :expiration_month => expiration_month,
                :expiration_year => expiration_year ]
    hash[:token] = token if token.present?
    hash
  end
  
  private
    def valid_checksum?
      sum = 0
      for i in 0..self.number.length
        weight = self.number[-1 * (i + 2), 1].to_i * (2 - (i % 2))
        sum += (weight < 10) ? weight : weight - 9
      end
      
      (self.number[-1,1].to_i == (10 - sum % 10) % 10)
    end
    
    def expired?
      Time.now.utc > expiration
    end
    
    def expiration
      begin
        Time.utc(expiration_year.to_i, expiration_month.to_i, month_days, 23, 59, 59)
      rescue ArgumentError
        Time.at(0).utc
      end
    end
    
    def month_days
      mdays = [nil,31,28,31,30,31,30,31,31,30,31,30,31]
      mdays[2] = 29 if Date.leap?(expiration_year.to_i)
      mdays[expiration_month.to_i]
    end
end