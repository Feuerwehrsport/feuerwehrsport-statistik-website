# frozen_string_literal: true

# Dialogs for contributions of visitors (anonymous login via ApiUser or admin login). The views render into the
# turbo frame "contribution" inside the <dialog> of the layout.
class Contributions::BaseController < ApplicationController
  include Api::LoginActions # current_user: admin user or anonymous api user

  layout 'contribution'
  before_action :require_contributor

  private

  def require_contributor
    return if current_user

    redirect_to new_contributions_login_path(return_to: request.fullpath)
  end

  # same entries as the api did before (ChangeLogSupport)
  def log_change(record, serializer:, action: "#{action_name}-#{record.class.name.parameterize}", before_hash: nil)
    attributes = { model_class: record.class, user: current_user, action:,
                   after_hash: serializer.new(record.decorate).as_json }
    attributes[:before_hash] = before_hash if before_hash
    ChangeLog.create!(attributes)
  end

  # change request for the administrators (same content format as before via the api: key + data)
  def create_change_request(key, data, files = [])
    change_request = ChangeRequest.new(content: { key:, data: }, user: current_user, files:)
    ChangeRequest.transaction do
      change_request.save!
      log_change(change_request, serializer: ChangeRequestSerializer)
    end
    ChangeRequestMailer.with(change_request:).new_notification.deliver_later
    change_request
  end

  # person at a position of a group score ("Positionen bearbeiten"), same change log as the former api
  def assign_group_score_person(group_score, position, person)
    before_hash = GroupScoreSerializer.new(group_score.decorate).as_json
    changed = GroupScore.transaction do
      next false unless group_score.assign_person!(position, person)

      log_change(group_score.reload, serializer: GroupScoreSerializer, action: 'update-groupscore:participation',
                                     before_hash:)
      true
    end
    clean_cache if changed
  end

  def clean_cache
    Caching::Cleaner.new.save
  end
end
