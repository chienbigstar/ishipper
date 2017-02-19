class NotificationServicesNodejs::CreateNotificationServiceNodejs
  attr_reader :args

  def initialize args
    @owner = args[:owner]
    @recipient = args[:recipient]
    @status = args[:status]
    @invoice = args[:invoice]
    @click_action = args[:click_action]
    @invoice_simple = args[:invoice_simple]
  end

  def perform
    @notification = Notification.create! owner_id: @owner.id, recipient_id: @recipient.id, status: @status, invoice_id: @invoice.id, click_action: @click_action
    user_setting = @recipient.user_setting
    if @notification
      user_setting.update! unread_notification: user_setting.unread_notification + 1
      if @recipient.online?
        data = Hash.new
        data[:unread_notification] = user_setting.unread_notification
        data[:channel] = "#{@recipient.phone_number}_realtime_channel"
        data[:invoice_id] = @invoice.id
        $redis.publish 'redis-change', data.to_json
      end
      if user_setting.receive_notification?
        Notifications::SendNotificationJob.perform_now notification: @notification,
          owner: @owner, recipient: @recipient, status: @status, invoice: @invoice,
          click_action: @click_action, invoice_simple: @invoice_simple
        notification_channel = "#{@recipient.phone_number}_notification_channel"
        Notifications::WebNotificationBroadcastJobNodejs.perform_now channel: notification_channel,
           owner: @owner, invoice: @invoice, notification: @notification
      end
    end
  end
end
