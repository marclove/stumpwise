namespace :statements do
  desc "Batch out undisbursed transactions and send statements"
  task :weekly => :environment do
    disbursement_date = Time.zone.now.to_date
    Contribution.settled.each{|c| c.payout!}
    Contribution.update_all("disbursed_on = '#{disbursement_date}'", "disbursed_on IS NULL AND status IN ('declined', 'voided', 'paid', 'refunded')")
    Site.all.each{|s| s.generate_weekly_statement(disbursement_date)}
    Site.generate_weekly_summary_statement(disbursement_date)
  end
end