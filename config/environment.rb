# Load the Rails application.
require_relative 'application'

# Load settings into ENV if any.
if Settings.ENV
  Settings.ENV.each do |key, value|
    ENV[key.to_s] = value.to_s
  end
end

# Initialize the Rails application.
Rails.application.initialize!
