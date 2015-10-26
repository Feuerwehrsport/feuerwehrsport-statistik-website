class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  after_filter :save_html_cache, only: [:index, :show]

  def save_html_cache
    uri = URI.parse(request.url).path
    path = File.join(Rails.root, "public", "cache", File.dirname(uri))
    FileUtils.mkdir_p(path)
    File.open(File.join(path, "#{File.basename(uri)}.html"), "w+") do |f|
      f.write(response.body)
    end
  end
end
