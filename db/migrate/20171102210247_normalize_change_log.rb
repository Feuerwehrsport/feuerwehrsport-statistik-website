class NormalizeChangeLog < ActiveRecord::Migration
  def change
    change_column_null :change_logs, :action_name, true
    add_column :change_logs, :action, :string, length: 200

    {
      'add-appointment' => 'create-appointment',
      'add-competition' => 'create-competition',
      'add-event' => 'create-event',
      'add-group-score-type' => 'create-groupscoretype',
      'add-link' => 'create-link',
      'add-person' => 'create-person',
      'add-place' => 'create-place',
      'add-team' => 'create-team',
      'edit-appointment' => 'update-appointment',
      'merge' => 'merge',
      'update-logo' => 'update-team:image',
      'update-nation' => 'update-person:nation',
      'update-participation' => 'update-groupscore:participation',
      'update-score-type' => 'update-competition:score-type',
      'update-state' => 'update-team:state',
    }.each { |from, to| ChangeLog.where(log_action: from).update_all(log_action: nil, action: to) }

    ChangeLog.where(log_action: 'update-team', model_class: 'Score').update_all(log_action: nil, action: 'update-score:team')
    ChangeLog.where(log_action: 'update-team', model_class: 'GroupScore').update_all(log_action: nil, action: 'update-groupscore:team')
    ChangeLog.where(log_action: 'update-geo-position', model_class: 'Team').update_all(log_action: nil, action: 'update-team:geo-position')
    ChangeLog.where(log_action: 'update-geo-position', model_class: 'Place').update_all(log_action: nil, action: 'update-place:geo-position')
    ChangeLog.where(log_action: 'update-name', model_class: 'Team').update_all(log_action: nil, action: 'update-team:name')
    ChangeLog.where(log_action: 'update-name', model_class: 'Competition').update_all(log_action: nil, action: 'update-competition:name')
    ChangeLog.where(log_action: 'update-name', model_class: 'Person').update_all(log_action: nil, action: 'update-person:name')
    ChangeLog.where(log_action: 'files-competitionfile', model_class: 'CompetitionFile').update_all(log_action: nil, action: 'create-competitionfile')
    ChangeLog.where(action: nil).where.not(action_name: nil).each do |change_log|
      change_log.update_column(:action, "#{change_log.action_name}-#{change_log.model_class.parameterize}")
      change_log.update_column(:log_action, nil)
    end
    ChangeLog.where(model_class: 'News').each do |change_log|
      change_log.update_column(:action, "#{change_log.action_name}-#{'NewsArticle'.parameterize}", model_class: 'NewsArticle')
    end
    change_column_null :change_logs, :action, false
    remove_column :change_logs, :log_action
    remove_column :change_logs, :action_name
  end
end
