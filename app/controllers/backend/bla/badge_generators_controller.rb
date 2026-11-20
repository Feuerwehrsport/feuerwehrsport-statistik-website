# frozen_string_literal: true

class Backend::Bla::BadgeGeneratorsController < Backend::BackendController
  backend_actions :new

  def new
    super
    respond_to do |format|
      format.html
      format.xlsx do
        xlsx = Bla::BadgeGenerator::Xlsx.new(resource, request.base_url)
        send_data(xlsx.to_stream, filename: xlsx.filename, type: Mime[:xlsx])
      end
    end
  end
end
