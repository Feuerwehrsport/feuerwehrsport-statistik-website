# frozen_string_literal: true

require 'rails_helper'

# two-click solution (ui/_youtube_video, stimulus video-consent)
describe 'YouTube videos' do
  before { page.driver.browser.url_blocklist = [/youtube/] } # no requests to YouTube from the specs

  it 'loads nothing from YouTube until a video is started' do
    visit feuerwehrsport_path
    expect(page).to have_button('Video abspielen', count: 5)
    expect(page).to have_no_css('iframe')
    expect(page.driver.network_traffic.map(&:url).grep(/youtube/)).to be_empty

    within('.col-md-6', text: 'Hindernisbahn') { click_on 'Video abspielen' }
    iframe = find('iframe[title="Einführungsvideo Hindernisbahn"]')
    expect(iframe[:src]).to eq 'https://www.youtube-nocookie.com/embed/BPsXhdzzkJ4?autoplay=1'
    expect(page).to have_button('Video abspielen', count: 4)
  end
end
