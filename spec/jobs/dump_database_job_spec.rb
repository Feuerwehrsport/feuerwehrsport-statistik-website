# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DumpDatabaseJob do
  describe '#perform' do
    it 'builds the correct command and calls system' do
      expected_excludes = '--exclude-table-data=admin_users ' \
                          '--exclude-table-data=api_users ' \
                          '--exclude-table-data=change_logs ' \
                          '--exclude-table-data=change_requests ' \
                          '--exclude-table-data=import_request_files ' \
                          '--exclude-table-data=import_requests ' \
                          '--exclude-table-data=m3_assets ' \
                          '--exclude-table-data=m3_logins ' \
                          '--exclude-table-data=solid_queue_blocked_executions ' \
                          '--exclude-table-data=solid_queue_claimed_executions ' \
                          '--exclude-table-data=solid_queue_failed_executions ' \
                          '--exclude-table-data=solid_queue_jobs ' \
                          '--exclude-table-data=solid_queue_pauses ' \
                          '--exclude-table-data=solid_queue_processes ' \
                          '--exclude-table-data=solid_queue_ready_executions ' \
                          '--exclude-table-data=solid_queue_recurring_executions ' \
                          '--exclude-table-data=solid_queue_recurring_tasks ' \
                          '--exclude-table-data=solid_queue_scheduled_executions ' \
                          '--exclude-table-data=solid_queue_semaphores ' \
                          '--exclude-table-data=tags'

      script_path = Rails.root.join('etc/store_dump.sh')
      expected_command = %(#{script_path} "#{expected_excludes}" "feuerwehrsport-statistik")

      expect_any_instance_of(described_class)
        .to receive(:system)
        .with(expected_command)

      described_class.perform_now
    end
  end
end
