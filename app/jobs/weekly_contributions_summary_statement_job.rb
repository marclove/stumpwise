class WeeklyContributionsSummaryStatementJob < Struct.new(:disbursement_date)
  def perform
    WeeklyContributions.deliver_summary_statement(disbursement_date)
  end
end