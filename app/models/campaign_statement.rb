class CampaignStatement < ActiveRecord::Base
  belongs_to :site
  has_many :contributions
end
