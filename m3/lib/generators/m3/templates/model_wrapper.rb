class <%= model_wrapper_class_name %> < <%= wrapped_model_class_name %>
  # Do not forget to override association classes to wrappers:
  # belongs_to :something, class_name: 'Wrapped::Something'
end
