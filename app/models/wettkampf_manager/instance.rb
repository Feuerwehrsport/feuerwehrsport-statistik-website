# frozen_string_literal: true

WettkampfManager::Instance = Struct.new(:date, :description, :slug) do
  def self.all
    json = JSON.parse(File.read(Rails.configuration.wettkampf_manager_config_path), symbolize_names: true)
    json.map { |c| new(Date.parse(c[:date]), c[:description], c[:name]) }
  end

  def current?
    date > 7.days.ago
  end

  def url
    "https://#{slug}.feuerwehrsport-statistik.de"
  end
end
