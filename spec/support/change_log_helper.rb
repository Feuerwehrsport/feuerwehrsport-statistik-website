# frozen_string_literal: true

def expect_change_log(before: nil, after: nil, klass: nil, log: nil)
  expect(ChangeLog.count).to eq 1
  change_log = ChangeLog.last
  if login_user.is_a?(ApiUser)
    expect(change_log.api_user).to eq login_user
  else
    expect(change_log.admin_user).to eq login_user
  end

  klass ||= controller.resource_class
  expect(change_log.model_class).to eq klass.name

  if before
    expect(change_log.content[:before_hash]).to include before
  else
    expect(change_log.content[:before_hash]).to be_nil
  end

  if after
    expect(change_log.content[:after_hash]).to include after
  else
    expect(change_log.content[:after_hash]).to be_nil
  end

  expect(change_log.action).to eq log
end

def expect_no_change_log
  expect(ChangeLog.count).to eq 0
end
