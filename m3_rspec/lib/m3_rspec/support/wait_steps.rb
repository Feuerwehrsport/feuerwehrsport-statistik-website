# frozen_string_literal: true

# Matchers that will wait for a value to change.

require 'timeout'

# Ex. expect { email.reload.delivered? }.to become_true
RSpec::Matchers.define :become_true do
  supports_block_expectations
  match do |block|
    Timeout.timeout(Capybara.default_max_wait_time) do
      sleep(0.1) until (value = block.call)
      value
    end
  rescue TimeoutError
    false
  end
end

RSpec::Matchers.define :become_false do
  supports_block_expectations
  match do |block|
    Timeout.timeout(Capybara.default_max_wait_time) do
      sleep(0.1) until (value = !block.call)
      value
    end
  rescue TimeoutError
    false
  end
end

# Ex. expect { page.current_url }.to become( '/#/something_or_other' )
RSpec::Matchers.define :become do |expected|
  supports_block_expectations
  match do |block|
    Timeout.timeout(Capybara.default_max_wait_time) do
      sleep(0.1) until (value = (block.call == expected))
      value
    end
  rescue TimeoutError
    false
  end
end
