# frozen_string_literal: true

FactoryBot.define do
  factory :link do
    label { 'Bericht auf Feuerwehrsport Team-MV' }
    linkable factory: :competition
    url { 'http://www.feuerwehrsport-teammv.de/2012/08/24-08-2012-3-mv-steigercup-kagsdorf/' }
  end
end
