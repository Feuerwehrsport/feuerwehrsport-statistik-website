# frozen_string_literal: true
class CarrierStringIO < StringIO
  attr_reader :original_filename, :content_type
  def initialize(data, filename, content_type)
    super(data)
    @original_filename = filename
    @content_type = content_type
  end
end
