FactoryBot.define do
  factory :import_request do
    url { 'http://foobar.com/test' }
    place { Place.first || build(:place) }
    event { Event.first || build(:event) }
    date { Date.parse('2013-09-21') }
    description { 'Am 21.09.2013 fand das Finale des Deutschland-Cups in Charlottenthal statt.' }
    admin_user { AdminUser.first || build(:admin_user) }
    import_request_files { [build(:import_request_file)] }
  end

  factory :import_request_file do
    file { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/testfile.pdf'), 'application/pdf') }
  end
end
