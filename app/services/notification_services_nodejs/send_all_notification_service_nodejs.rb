class NotificationServicesNodejs::SendAllNotificationServiceNodejs
  attr_reader :args

  def initialize args
    @owner = args[:owner]
    @recipients = args[:recipients]
    @status = args[:status]
    @invoice = args[:invoice]
    @click_action = args[:click_action]
    @invoice_simple = args[:invoice_simple]
  end

  def perform
    Notifications::SendNotificationAllJobNodejs.perform_now owner: @owner, recipients: @recipients,
      status: @status, invoice: @invoice, click_action: @click_action, invoice_simple: @invoice_simple
  end
end
