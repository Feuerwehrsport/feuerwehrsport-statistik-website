require "pathname"

module WettkampfManager
  class Version
    attr_reader :version_number, :targets

    def self.all
      Pathname.new(Rails.configuration.wettkampf_manager_path).children.select { |c| c.directory? }.map do |version_dir|
        new(version_dir)
      end.sort_by(&:version_number).reverse
    end

    def initialize(version_dir)
      @version_dir = version_dir
      @version_number = version_dir.basename
      @targets = Pathname.new(version_dir).children.select { |c| c.file? && c.basename.to_s != "release-info.json" }
    end

    def commit_id
      release_data["commit-id"]
    end

    def date
      release_data["date"]
    end

    def invalid?
      release_data["invalid"].present?
    end

    def invalid_message
      markdown(release_data["invalid"])
    end

    def change_log
      markdown(release_data["change-log"])
    end

    protected

    def markdown(message)
      Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(message).html_safe
    end

    def release_data
      @release_data ||= begin
        if File.file?("#{@version_dir}/release-info.json")
          JSON.parse(File.open("#{@version_dir}/release-info.json").read)
        else
          {}
        end
      end
    end
  end
end