Rails.application.config.middleware.use OmniAuth::Builder do
  provider :salesforce, ENV['CANVAS_CONSUMER_KEY'], ENV['CANVAS_CONSUMER_SECRET']
end