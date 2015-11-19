class PagesController < ResourceController
  def firesport_overview
    @page_title = "Feuerwehrsport - verschiedene Angebote"
  end

  def legal_notice
    @page_title = "Impressum"
  end
end