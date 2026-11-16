# frozen_string_literal: true

# change log entries and cache cleaning for controllers outside of the generic DefaultActions
# (same entries as ChangeLogSupport of the api)
module ChangeLogging
  extend ActiveSupport::Concern

  private

  def log_change(record, serializer:, action: "#{action_name}-#{record.class.name.parameterize}", before_hash: nil,
                 after: true)
    attributes = { model_class: record.class, user: current_user, action: }
    attributes[:after_hash] = serializer.new(record.decorate).as_json if after
    attributes[:before_hash] = before_hash if before_hash
    ChangeLog.create!(attributes)
  end

  def serialize_for_log(record, serializer)
    serializer.new(record.decorate).as_json
  end

  def clean_cache
    Caching::Cleaner.new.save
  end
end
