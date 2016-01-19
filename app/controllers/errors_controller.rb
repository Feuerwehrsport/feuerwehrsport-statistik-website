class ErrorsController < ApplicationController
  def not_found
    @page_title = "404 - Seite nicht gefunden"
    render(status: 404)
  end

  def internal_server_error
    @page_title = "500 - Interner Fehler"
    render(status: 500)
  end
end
