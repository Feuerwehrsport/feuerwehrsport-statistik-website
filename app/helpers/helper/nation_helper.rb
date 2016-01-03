module Helper::NationHelper
  def nation_flag(nation, options={})
    if nation.is_a?(Array)
      iso = nation.first
      name = nation.last
    else
      iso = nation.iso
      name = nation
    end
    options = { title: name, width: 16 }.merge(options)
    image_tag(asset_path("flags-iso/#{iso}.png"), options)
  end

  def nation_flag_with_iso(nation, options={})
    "<code class='small' title='#{nation}'>#{nation.iso.upcase} #{nation_flag(nation, options)}</code>".html_safe
  end
end