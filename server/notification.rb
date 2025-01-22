require 'fcm'

FIREBASE = if ENV.fetch('FCM_API_TOKEN', 'YOUR_FCM_API_KEY').empty? || ENV.fetch('FCM_PROJECT_ID', "YOUR_FCM_PROJECT_ID").empty?
  nil
else
  FCM.new(
    './fcm-credential.json',
    ENV.fetch('FCM_PROJECT_ID', 'YOUR_FCM_PROJECT_ID'),
    { timeout: 30 }
  )
end

DEMO_NOTI = { notification: { title: "Breaking News", body: "New news story available." },
              data: { story_id: "story_12345" },
              android: { notification: { click_action: "TOP_STORY_ACTIVITY", body: "Check out the Top Story" } },
              apns: { payload: { aps: { category: "NEW_MESSAGE_CATEGORY" } } } }

class Notification
  def initialize(topic:, tokens:, mess_hash: nil)
    @data = mess_hash || DEMO_NOTI
    @topic = topic
    @tokens = tokens
  end

  def send_to_topic
    noti = data.clone.merge(topic: topic)
    res = FIREBASE.send_v1(noti)
    log_response(res)
  rescue StandardError => e
    log_error(e)
  end

  def send_to_device(device_tk)
    noti = data.clone.merge(token: device_tk)
    res = FIREBASE.send_v1(noti)
    log_response(res)
  rescue StandardError => e
    log_error(e)
  end

  def send_all_devices
    tokens.each do |device_tk|
      send_to_device(device_tk)
    end
  end

  def subscribe
    res = FIREBASE.batch_topic_subscription(topic, tokens)
    log_response(res)
  rescue StandardError => e
    log_error(e)
  end

  def unsubscribe
    res = FIREBASE.batch_topic_unsubscription(topic, tokens)
    log_response(res)
  rescue StandardError => e
    log_error(e)
  end

  private

  attr_reader :tokens, :topic, :data

  def log_response(response)
    puts "Response: #{response}"
  end

  def log_error(error)
    puts "Error: #{error.message}"
  end
end

