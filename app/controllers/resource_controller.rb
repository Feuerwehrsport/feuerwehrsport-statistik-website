class ResourceController < ApplicationController
  include ResourceAccess

  helper_method def page_title
    @page_title || resource_class.model_name.human(count: 0)
  end
end