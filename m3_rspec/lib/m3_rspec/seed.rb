# frozen_string_literal: true

require 'database_cleaner/active_record/truncation'
class DatabaseCleaner::ActiveRecord::Truncation
  def clean_with_seed
    clean_without_seed
    M3Rspec::Seed.new.perform
  end

  alias clean_without_seed clean
  alias clean clean_with_seed
end

class M3Rspec::Seed
  class_attribute :block
  class_attribute :version_checked

  def perform
    return if block.blank?

    if ENV['GENERATE_DUMP'].blank? && version_matches
      load_dump
    else
      block.call
      generate_dump
    end
  end

  def version_matches
    M3Rspec::Seed.version_checked ||= File.file?(seed_path) && File.read(seed_path).include?(version_comment)
  end

  def seed_path
    @seed_path ||= Rails.root.join('db/rspec_seed.sql')
  end

  def load_dump
    `psql #{pg_options}`
  end

  def generate_dump
    `pg_dump #{pg_options} -a -T schema_migrations -T ar_internal_metadata`
    File.open(seed_path, 'a') { |f| f.puts(version_comment) }
  end

  def version_comment
    ActiveRecord::SchemaMigration.all.map(&:version).sort.map { |v| "-- seed-contain: #{v} :seed-contain" }.join("\n")
  end

  def pg_options
    config = ActiveRecord::Base.connection.instance_variable_get(:@config)
    connection_parameters = ActiveRecord::Base.connection.instance_variable_get(:@connection_parameters)
    "-U #{config[:username]} -h #{connection_parameters[:host]} -d #{config[:database]} -f #{seed_path}"
  end
end
