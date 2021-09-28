<%- module_namespacing do -%>
  <%- if parent_class_name.present? -%>
class <%= class_name %>Decorator < <%= parent_class_name %>
  <%- else -%>
class <%= class_name %>
  <%- end -%>
  # decorates_association :chapters
  # localizes :last_read_at, :last_finished_at
  # translates_collection_value :cover_type, :category

  def to_s
    object.to_s
  end
end
<% end -%>