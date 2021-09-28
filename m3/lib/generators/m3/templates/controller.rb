<% if namespaced? -%>
require_dependency "<%= namespaced_path %>/application_controller"

<% end -%>
<% module_namespacing do -%>
class <%= class_name %>Controller < ApplicationController
  default_actions <%= (actions.nil? || actions.empty?) ? '' : (actions.map{ |a| ":#{a}" }.join(', ') + ', ') %>for_class: <%= class_name.singularize %>
  <% if parent? %>belongs_to <%= parent_class_name %>, url: ->{ <%= parent_path %>(parent_resource) } #, parent_name: :<%= parent_name %>, child_name: :<%= parent_name %><% end -%>
  
  <% if actions.include?('index') %>default_index do |t|<% -%>
    <% if column_names? -%>
    <%   column_names.each do |column_name| %>
    t.col :<%= column_name -%>
    <%   end -%>
    <% else %>
    # t.col :user_name
    # t.col :full_name, sortable: :last_name
    # t.col :email_address, sortable: { login: :email_address }
    # t.col :number_of_friends, sortable: false<% end %>
  end<% end %>
  
  <% if (actions & %w{new create edit update}).size > 0 %>default_form do |f|<% -%>
    <% if column_names? %><% (column_names - %w(id created_at updated_at)).each do |column_name| %>
    <%   if column_name.end_with?('id') %>f.association :<%= column_name.chomp('_id') -%>
    <%   else %>f.input :<%= column_name %><% end -%>
    <% end %><% else %>
    # f.inputs :legend do
    #   f.input :name
    #   f.association :assoc_name, as: :select
    # end<% end %>
  end<% end %>
end
<% end -%>
