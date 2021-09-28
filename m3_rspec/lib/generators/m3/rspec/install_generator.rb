# frozen_string_literal: true

module M3
  module Rspec
    module Generators
      class InstallGenerator < Rails::Generators::Base
        desc 'Create local rspec configuration files for customization'
        source_root File.expand_path('templates', __dir__)

        def copy_template
          copy_file('rails_helper.rb', 'spec/rails_helper.rb')
          copy_file('spec_helper.rb', 'spec/spec_helper.rb')
          copy_file('.rspec', '.rspec')
          copy_file('Guardfile', 'Guardfile')

          path = "#{File.expand_path('templates', __dir__)}/"
          Dir["#{path}spec/**/*.rb"].each do |file|
            copy_file(file.gsub(path, ''), file.gsub(path, ''))
          end
        end
      end
    end
  end
end
