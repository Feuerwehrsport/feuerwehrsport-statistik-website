# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UiHelper do
  describe '#rich_text' do
    it 'keeps the tags of the editor' do
      html = '<div>Text <strong>fett</strong> <em>kursiv</em><br><a href="https://example.com">Link</a></div>' \
             '<ul><li>Punkt</li></ul>'
      expect(helper.rich_text(html)).to eq html
    end

    it 'removes scripts, styles and event handlers' do
      html = '<p onclick="alert(1)" style="color:red">Hallo</p><script>alert(1)</script><img src="x" onerror="y">'
      expect(helper.rich_text(html)).to eq '<p>Hallo</p>alert(1)'
    end
  end
end
