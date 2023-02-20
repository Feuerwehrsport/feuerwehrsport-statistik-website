# frozen_string_literal: true
FactoryBot.define do
  factory :competition_file do
    competition { Competition.first || build(:competition) }
    file { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/testfile.pdf'), 'application/pdf') }
    keys_string { 'hb,hl' }
  end
end
