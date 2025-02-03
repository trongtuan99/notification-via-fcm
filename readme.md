# Gửi thông báo đến một topic

notification = Notification.new(topic: "news")
notification.send_to_topic

# Gửi thông báo đến một thiết bị cụ thể

notification = Notification.new(tokens: ["device_token_1"])
notification.send_to_device("device_token_1")

# Gửi thông báo đến nhiều thiết bị

notification = Notification.new(tokens: ["device_token_1", "device_token_2"])
notification.send_to_devices

# Đăng ký nhiều thiết bị vào một topic

notification = Notification.new(topic: "news", tokens: ["device_token_1", "device_token_2"])
notification.subscribe

# Hủy đăng ký nhiều thiết bị khỏi một topic

notification.unsubscribe
