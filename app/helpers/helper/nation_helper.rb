module Helper::NationHelper
  def nation_flag(nation, options={})
    options = { title: nation, width: 16 }.merge(options)
    image_tag(asset_path("flags-iso/#{nation.iso}.png"), options)
  end

  def nation_flag_with_iso(nation, options={})
    "<code class='small' title='#{nation}'>#{nation.iso.upcase} #{nation_flag(nation, options)}</code>".html_safe
  end
end