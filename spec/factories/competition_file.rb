FactoryGirl.define do
  factory :competition_file do
    competition { Competition.first || build(:competition) }
    file { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/testfile.pdf')), 'application/pdf') }
    keys_string 'hb,hl'
  end
end
