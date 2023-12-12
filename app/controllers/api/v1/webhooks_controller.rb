class Api::V1::WebhooksController < ApplicationController
  skip_before_action :authenticate_user!

  ## POST /api/v1/webhooks/stripe
  ## Stripe webhook endpoint for receiving events from Stripe
  def stripe
    payload = request.body.read
    event = nil

    begin
      event = Stripe::Event.construct_from(JSON.parse(payload, symbolize_names: true))
    rescue JSON::ParserError => e
      return head :bad_request
    end

    case event.type
    when 'customer.subscription.deleted', 'customer.subscription.created', 'customer.subscription.updated'
      UserSubscription.update_subscription_via_webhook_event(event)
    when 'invoice.deleted', 'invoice.created', 'invoice.updated'
      UserInvoice.update_invoice_via_webhook_event(event)
    else
      return head :bad_request
    end

    head :ok
  end
end
