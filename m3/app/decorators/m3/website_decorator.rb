# frozen_string_literal: true

class M3::WebsiteDecorator < ApplicationDecorator
  decorates_association :pages

  def main_menu_pages
    pages.select { |page| page.persisted? && page.satisfied? && page.menu_label.present? }
  end

  def to_s
    name
  end
end
