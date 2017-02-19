class Notifications::SendNotificationAllJobNodejs < ActiveJob::Base
  queue_as :default

  def perform args
    args[:recipients].each do |recipient|
      NotificationServicesNodejs::CreateNotificationServiceNodejs.new(owner: args[:owner],
        recipient: recipient, status: args[:status], invoice: args[:invoice],
        click_action: args[:click_action], invoice_simple: args[:invoice_simple]).perform
    end
  end
end
