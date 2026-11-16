# frozen_string_literal: true

class DumpDatabaseJob < ApplicationJob
  def perform
    script_path = Rails.root.join('etc/store_dump.sh')
    exclude_file = Rails.root.join('config/dump_exclude_tables')

    exclude_tables = File.read(exclude_file)
                         .split("\n")
                         .compact_blank
                         .map { |table| "--exclude-table-data=#{table}" }
                         .join(' ')

    command = [script_path.to_s, exclude_tables, 'feuerwehrsport-statistik']

    Rails.logger.info "Executing dump command: #{command.join(' ')}"

    # argument list instead of a single string: no shell is involved
    system(*command)
  end
end
