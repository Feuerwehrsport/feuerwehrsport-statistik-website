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

    command = %(#{script_path} "#{exclude_tables}" "feuerwehrsport-statistik")

    Rails.logger.info "Executing dump command: #{command}"

    system(command)
  end
end
