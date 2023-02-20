# frozen_string_literal: true

class M3::Generators::ControllerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)
  check_class_collision suffix: 'Controller'
  argument :actions, type: :array, default: %w[index new create show edit update destroy], banner: 'index new ...'
  class_option :parent, type: :string, default: nil, banner: 'reading/books',
                        desc: 'Sets a parent controller'
  class_option :column_model, type: :string, default: nil, banner: 'Reading::Chapter',
                              desc: 'Reads columns from given model to prefil index and form'
  class_option :model_wrapper_for, type: :string, default: nil, banner: 'Reading::Chapter',
                                   desc: 'Creates a wrapper model for the given one'

  def create_controller_files
    template 'controller.rb', File.join('app/controllers', class_path, "#{file_name}_controller.rb")
  end

  def add_routes
    return if options[:skip_routes]

    route generate_routing_code(actions)[2..]
    puts '💡 Remember to position the generated route correctly in routes.rb'
  end

  def create_model_wrapper
    return unless wrap_model?

    template 'model_wrapper.rb', File.join('app/models', class_path, "#{file_name.singularize}.rb")
    puts <<~HEREDOC
        💡 Remember abilities for model wrapper #{model_wrapper_class_name}, e.g.:
          can(:read, #{model_wrapper_class_name}, user_id: user.id)
      HEREDOC
  end

  private

  def wrap_model?
    options[:model_wrapper_for].present?
  end

  def wrapped_model_class_name
    options[:model_wrapper_for].to_s.classify
  end

  def wrapped_model_class
    wrapped_model_class_name.constantize
  end

  def model_wrapper_class_name
    class_name.singularize
  end

  def column_names?
    column_model_class_name.present?
  end

  def column_model_class_name
    (options[:column_model] || options[:model_wrapper_for]).to_s.classify
  end

  def column_model_class
    column_model_class_name.constantize
  end

  def column_names
    column_model_class.column_names
  end

  def parent?
    options[:parent]
  end

  def parent_name
    options[:parent].to_s.singularize.underscore.split('/').last
  end

  def parent_route_name
    options[:parent].to_s.pluralize.underscore.split('/').last
  end

  def parent_class_name
    options[:parent].to_s.classify
  end

  def parent_path
    "#{options[:parent].to_s.singularize.underscore.tr('/', '_')}_path"
  end

  def generate_routing_code(actions)
    depth = regular_class_path.length
    # Create 'namespace' ladder
    # namespace :foo do
    #   namespace :bar do
    namespace_ladder = regular_class_path.each_with_index.map do |ns, i|
      indent("  namespace :#{ns} do\n", i * 2)
    end.join

    route = ''
    if parent?
      route += indent(%(  resources :#{parent_route_name}, only: [] do\n), depth * 2)
      depth += 1
    end

    # Create route
    #     get 'baz/index'
    action_string = actions.map { |a| ":#{a}" }.join(', ')
    route += indent(%(  resources :#{file_name}, only: [#{action_string}]\n), depth * 2)

    if parent?
      depth -= 1
      route += indent(%(  end\n), depth * 2)
    end

    # Create `end` ladder
    #   end
    # end
    end_ladder = (1..depth).reverse_each.map do |i|
      indent("end\n", i * 2)
    end.join

    # Combine the 3 parts to generate complete route entry
    namespace_ladder + route + end_ladder
  end
end
