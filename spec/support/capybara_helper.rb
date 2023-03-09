# frozen_string_literal: true

module M3Rspec::CapybaraHelper
  class Screenshots
    class_attribute :save_review_screenshot_number
    class << self
      def m3_compare_and_open_screenshots
        return if Screenshots.save_review_screenshot_number.nil? || Screenshots.save_review_screenshot_number == 0

        changes = []
        comparision_image = nil
        fixtures = Dir.glob("#{screenshot_fixture_directory}/*.png")
        Dir.glob("#{review_screenshot_directory}/*.png").each do |screenshot|
          basename = File.basename(screenshot)
          fixture = fixtures.detect { |path| path.end_with?(basename) }
          if fixture
            img1 = Phashion::Image.new(screenshot)
            img2 = Phashion::Image.new(fixture)
            if img1.duplicate?(img2, threshold: 0)
              FileUtils.rm(screenshot)
            else
              comp_path = "#{review_screenshot_directory}/compare/CHANGED: #{basename}"
              FileUtils.cp(screenshot, comp_path)
              FileUtils.cp(fixture, "#{review_screenshot_directory}/compare/CHANGED: #{basename}.ORIGINAL.png")
              changes << screenshot
              comparision_image ||= comp_path
            end
          else
            comp_path = "#{review_screenshot_directory}/compare/NEW: #{basename}"
            FileUtils.cp(screenshot, comp_path)
            changes << screenshot
            comparision_image = comp_path if comparision_image.nil?
          end
        end
        open_screenshots(changes, comparision_image) unless changes.empty?
      end

      def screenshot_fixture_directory
        Rails.root.join('spec/fixtures/screenshots')
      end

      def open_screenshots(changes, comparision_image)
        puts ''
        puts ''
        puts "Screenshots added or changed: #{changes.size}"
        puts "xdg-open \"#{comparision_image}\""
        puts ''
        puts 'Accept all changes after review:'
        puts "cp #{review_screenshot_directory}/*.png #{screenshot_fixture_directory}/"
        puts ''
        `xdg-open "#{comparision_image}" &` if M3Rspec.configuration.open_screenshots?
      end

      def next_screenshot
        Screenshots.save_review_screenshot_number ||= 0
        Screenshots.save_review_screenshot_number += 1
        create_review_directories if Screenshots.save_review_screenshot_number == 1
        clear_review_screenshot_directory if Screenshots.save_review_screenshot_number == 1
      end

      def create_review_directories
        FileUtils.mkdir_p(Screenshots.screenshot_fixture_directory)
        FileUtils.mkdir_p(review_screenshot_directory)
        FileUtils.mkdir_p("#{review_screenshot_directory}/compare")
      end

      def clear_review_screenshot_directory
        FileUtils.rm(Dir.glob("#{review_screenshot_directory}/*.png"))
        FileUtils.rm(Dir.glob("#{review_screenshot_directory}/compare/*.png"))
      end

      def review_screenshot_directory
        dir_name = Rails.application.class.module_parent_name.parameterize
        "/tmp/#{dir_name}"
      end
    end
  end

  def save_review_screenshot(name = nil, file_name = nil)
    return if M3Rspec.configuration.screenshots_disabled

    sleep M3Rspec.configuration.screenshot_sleep if M3Rspec.configuration.screenshot_sleep?
    Screenshots.next_screenshot
    @review_screenshot_number += 1
    expect_no_missing_translations
    file_name ||= review_screenshot_basename(name, @example, @review_screenshot_number)
    full_path = "#{Screenshots.review_screenshot_directory}/#{file_name}"
    page.save_screenshot(full_path, full: true)
  end

  def review_screenshot_basename(name, example, screenshot_number)
    id = example.id.gsub('./spec/features/', '').gsub('.rb', '').parameterize
    description = @example.description.tr('/', '-')
    description = name if name.present?
    "#{description} (#{id} #{screenshot_number}).png"
  end

  def expect_no_missing_translations
    missings = page.source.scan(%r{translation missing: ([a-zA-Z0-9_./]+)})
    message = "Missing translations: #{missings.size}\n  " + missings.join("\n  ")
    expect(missings).to be_empty, message
  end

  def fill_in_and_wait(locator = nil, with:, currently_with: nil, fill_options: {}, **find_options)
    fill_in(locator, with: with, currently_with: currently_with, fill_options: fill_options, **find_options)
    find(:fillable_field, locator, with: with)
  end
end
