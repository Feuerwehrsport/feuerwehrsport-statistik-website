# frozen_string_literal: true

class Backend::People::CleanersController < Backend::BackendController
  backend_actions :show

  default_show do |i|
    i.col :people
  end

  protected

  def find_resource
    resource_class.new
  end
end
