# frozen_string_literal: true

module M3::Generators
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def run_other_generators
      generate 'delayed_job'
    end

    def create_schedule_file
      template 'schedule.rb', 'config/schedule.rb'
    end

    def copy_ckeditor
      directory File.expand_path('templates/ckeditor', __dir__), 'public/ckeditor'
    end

    def copy_decorator_template
      copy_file 'decorator.rb', 'lib/templates/rails/decorator/decorator.rb'
    end
  end
end
