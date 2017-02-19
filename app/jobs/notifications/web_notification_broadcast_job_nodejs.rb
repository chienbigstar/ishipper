class Notifications::WebNotificationBroadcastJobNodejs < ActiveJob::Base
  queue_as :default

  def perform args
    $redis.publish  args[:channel], {owner: args[:owner],
      invoice: args[:invoice], notification: args[:notification]}.to_json
  end
end
