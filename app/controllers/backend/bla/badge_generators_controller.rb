# frozen_string_literal: true

class Backend::Bla::BadgeGeneratorsController < Backend::BackendController
  backend_actions :new

  def new
    super
    respond_to do |format|
      format.html
      format.xlsx { send_xlsx(Bla::BadgeGenerator::Xlsx.new(resource, request.base_url)) }
    end
  end
end
