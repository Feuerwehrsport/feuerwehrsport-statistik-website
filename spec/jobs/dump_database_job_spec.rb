# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DumpDatabaseJob do
  describe '#perform' do
    it 'builds the correct command and calls system' do
      expected_excludes = '--exclude-table-data=admin_users ' \
                          '--exclude-table-data=api_users ' \
                          '--exclude-table-data=api_users_id_seq ' \
                          '--exclude-table-data=change_logs ' \
                          '--exclude-table-data=change_logs_id_seq ' \
                          '--exclude-table-data=change_requests ' \
                          '--exclude-table-data=import_request_files ' \
                          '--exclude-table-data=import_request_files_id_seq ' \
                          '--exclude-table-data=import_requests ' \
                          '--exclude-table-data=import_requests_id_seq ' \
                          '--exclude-table-data=m3_assets ' \
                          '--exclude-table-data=m3_logins ' \
                          '--exclude-table-data=solid_queue_blocked_executions ' \
                          '--exclude-table-data=solid_queue_blocked_executions_id_seq ' \
                          '--exclude-table-data=solid_queue_claimed_executions ' \
                          '--exclude-table-data=solid_queue_claimed_executions_id_seq ' \
                          '--exclude-table-data=solid_queue_failed_executions ' \
                          '--exclude-table-data=solid_queue_failed_executions_id_seq ' \
                          '--exclude-table-data=solid_queue_jobs ' \
                          '--exclude-table-data=solid_queue_jobs_id_seq ' \
                          '--exclude-table-data=solid_queue_pauses ' \
                          '--exclude-table-data=solid_queue_pauses_id_seq ' \
                          '--exclude-table-data=solid_queue_processes ' \
                          '--exclude-table-data=solid_queue_processes_id_seq ' \
                          '--exclude-table-data=solid_queue_ready_executions ' \
                          '--exclude-table-data=solid_queue_ready_executions_id_seq ' \
                          '--exclude-table-data=solid_queue_recurring_executions ' \
                          '--exclude-table-data=solid_queue_recurring_executions_id_seq ' \
                          '--exclude-table-data=solid_queue_recurring_tasks ' \
                          '--exclude-table-data=solid_queue_recurring_tasks_id_seq ' \
                          '--exclude-table-data=solid_queue_scheduled_executions ' \
                          '--exclude-table-data=solid_queue_scheduled_executions_id_seq ' \
                          '--exclude-table-data=solid_queue_semaphores ' \
                          '--exclude-table-data=solid_queue_semaphores_id_seq'

      script_path = Rails.root.join('etc/store_dump.sh')
      expected_command = %(#{script_path} "#{expected_excludes}" "feuerwehrsport-statistik")

      expect_any_instance_of(described_class)
        .to receive(:system)
        .with(expected_command)

      described_class.perform_now
    end
  end
end
