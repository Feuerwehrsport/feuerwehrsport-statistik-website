# frozen_string_literal: true

class Backend::ImportsController < Backend::BackendController
  def index
    authorize!(:manage, Competition)
  end
end
