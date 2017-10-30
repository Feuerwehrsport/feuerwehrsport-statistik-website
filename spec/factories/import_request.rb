FactoryGirl.define do
  factory :import_request do
    file { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/testfile.pdf'))) }
    url 'http://foobar.com/test'
    place { Place.first || build(:place) }
    event { Event.first || build(:event) }
    date Date.parse('2013-09-21')
    description 'Am 21.09.2013 fand das Finale des Deutschland-Cups in Charlottenthal statt.'
    admin_user { AdminUser.first || build(:admin_user) }
  end
end
