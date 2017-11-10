FactoryBot.define do
  factory :link do
    label 'Bericht auf Feuerwehrsport Team-MV'
    linkable { build(:competition) }
    url 'http://www.feuerwehrsport-teammv.de/2012/08/24-08-2012-3-mv-steigercup-kagsdorf/'
  end
end
