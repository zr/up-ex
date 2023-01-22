# frozen_string_literal: true

module LoginSupport
  def login(user)
    login_user(user, 'Passw0rd', session_path)
  end
end

RSpec.configure do |config|
  config.include LoginSupport
end
