# frozen_string_literal: true

# "Link hinzufügen" for teams and competitions
class Contributions::LinksController < Contributions::BaseController
  LINKABLE_TYPES = { 'Team' => Team, 'Competition' => Competition }.freeze

  before_action :assign_linkable

  def new
    @link = Link.new(linkable: @linkable)
    authorize!(:create, @link)
  end

  def create
    @link = Link.new(linkable: @linkable, label: params.dig(:link, :label).to_s.strip,
                     url: self.class.normalize_url(params.dig(:link, :url)))
    authorize!(:create, @link)

    @error = 'Bitte gib eine gültige Adresse an (zum Beispiel https://www.feuerwehr.de).' unless valid_url?(@link.url)
    saved = @error.nil? && Link.transaction { @link.save && log_change(@link, serializer: LinkSerializer) }
    if saved
      clean_cache
      render :created
    else
      render :new, status: :unprocessable_content
    end
  end

  # adds a missing scheme like the former JavaScript did ("www.example.com", "http://https://...")
  def self.normalize_url(url)
    url = url.to_s.strip.sub(%r{\Ahttps?://(https?://)}i, '\1')
    url.match?(%r{\Ahttps?://}i) || url.blank? ? url : "https://#{url}"
  end

  private

  def assign_linkable
    klass = LINKABLE_TYPES.fetch(params[:linkable_type].to_s) { raise ActiveRecord::RecordNotFound }
    @linkable = klass.find(params[:linkable_id])
  end

  def valid_url?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) && uri.host.present?
  rescue URI::InvalidURIError
    false
  end
end
