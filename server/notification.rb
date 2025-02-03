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

DEMO_NOTI = {
  notification: { title: "Breaking News", body: "New news story available." },
  data: { story_id: "story_12345" },
  android: { notification: { click_action: "TOP_STORY_ACTIVITY", body: "Check out the Top Story" } },
  apns: { payload: { aps: { category: "NEW_MESSAGE_CATEGORY" } } }
}

class Notification
  attr_reader :tokens, :topic, :data

  def initialize(topic: nil, tokens: [], mess_hash: DEMO_NOTI)
    @data = mess_hash
    @topic = topic
    @tokens = Array(tokens)
  end

  def send_to_topic
    raise ArgumentError, "Topic is required" unless topic
    noti = data.merge(topic: topic)
    handle_response { FIREBASE.send_v1(noti) }
  end

  def send_to_device(device_tk)
    noti = data.merge(token: device_tk)
    handle_response { FIREBASE.send_v1(noti) }
  end

  def send_to_devices
    tokens.each { |device_tk| send_to_device(device_tk) }
  end

  def subscribe
    raise ArgumentError, "Topic and tokens are required" unless topic && tokens.any?
    handle_response { FIREBASE.batch_topic_subscription(topic, tokens) }
  end

  def unsubscribe
    raise ArgumentError, "Topic and tokens are required" unless topic && tokens.any?
    handle_response { FIREBASE.batch_topic_unsubscription(topic, tokens) }
  end

  private

  def handle_response
    response = yield
    log_response(response)
  rescue StandardError => e
    log_error(e)
  end

  def log_response(response)
    puts "Response: #{response}"
  end

  def log_error(error)
    puts "Error: #{error.message}"
  end
end