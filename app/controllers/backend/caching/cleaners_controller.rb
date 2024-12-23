# frozen_string_literal: true

class Backend::Caching::CleanersController < Backend::BackendController
  backend_actions :new, :create, clean_cache_disabled: true

  default_form do |f|
    # do nothing
  end

  protected

  def collection_redirect_url
    backend_root_path
  end

  def resource_params
    {}
  end
end
