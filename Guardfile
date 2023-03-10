# frozen_string_literal: true

# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
directories(%w[app spec].select { |d| Dir.exist?(d) ? d : UI.warning("Directory #{d} does not exist") })

# This group allows to skip running RuboCop when RSpec failed.
group :red_green_refactor, halt_on_fail: true do
  guard :rspec, cmd: 'rspec' do
    require 'guard/rspec/dsl'
    dsl = Guard::RSpec::Dsl.new(self)

    # Feel free to open issues for suggestions and improvements

    # RSpec files
    rspec = dsl.rspec
    watch(rspec.spec_helper) { rspec.spec_dir }
    watch(rspec.spec_support) { rspec.spec_dir }
    watch(rspec.spec_files)

    # Ruby files
    ruby = dsl.ruby
    dsl.watch_spec_files_for(ruby.lib_files)

    # Rails files
    rails = dsl.rails(view_extensions: %w[erb haml slim])
    dsl.watch_spec_files_for(rails.app_files)
    dsl.watch_spec_files_for(rails.views)

    watch(rails.controllers) do |m|
      [
        rspec.spec.call("controllers/#{m[1]}_controller"),
        rspec.spec.call("requests/#{m[1]}_request"),
      ]
    end

    # Rails config changes
    watch(rails.spec_helper)     { rspec.spec_dir }
    watch(rails.app_controller)  { "#{rspec.spec_dir}/controllers" }

    # Capybara features specs
    watch(rails.view_dirs)     { |m| rspec.spec.call("features/#{m[1]}") }
    watch(rails.layouts)       { |m| rspec.spec.call("features/#{m[1]}") }
  end
end
