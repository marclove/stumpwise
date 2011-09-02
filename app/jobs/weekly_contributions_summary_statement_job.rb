class WeeklyContributionsSummaryStatementJob < Struct.new(:disbursement_date)
  def perform
    WeeklyContributions.summary_statement(disbursement_date)
  end
end