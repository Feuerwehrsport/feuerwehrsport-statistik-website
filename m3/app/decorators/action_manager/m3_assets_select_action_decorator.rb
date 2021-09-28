# frozen_string_literal: true

class ActionManager::M3AssetsSelectActionDecorator < ActionManager::MemberActionDecorator
  def url
    '#'
  end

  def link_to(options = {})
    super(options.merge(data: { m3_asset_url: resource.url, m3_asset_name: resource.name }))
  end
end
