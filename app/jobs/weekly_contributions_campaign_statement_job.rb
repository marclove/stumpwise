class WeeklyContributionsCampaignStatementJob < Struct.new(:statement_id)
  def perform
    WeeklyContributions.deliver_campaign_statement(CampaignStatement.find(statement_id))
  end
end