# frozen_string_literal: true

class M3::Generators::ViewGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)
  argument :actions, type: :array, default: %w[index show], banner: 'index index_table show'

  def create_view_files
    m3_view_path = "#{File.dirname(__dir__)}/../../app/views/application/"
    actions.each do |action|
      files = ["#{action}.html.haml", "#{action}.js.erb"]
      files += files.map { |name| "_#{name}" }
      files.each do |file|
        origin = "#{m3_view_path}#{file}"
        copy_file origin, File.join('app/views', file_path, file) if File.file?(origin)
      end
    end
  end
end
