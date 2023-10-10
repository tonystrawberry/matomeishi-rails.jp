# frozen_string_literal: true

##
## Job for analyzing a business card
##
class AnalyzeBusinessCard < CronJob
  queue_as :default

  def perform(business_card_id:)
    BusinessCard.find(business_card_id).analyze!
  end
end
