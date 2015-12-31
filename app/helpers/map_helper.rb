module MapHelper
  def map(options, &block)
    id = options.delete(:id) || 'map'
    html_classes = options.delete(:class) || 'map'
    map_data = {}
    red = options.delete(:red)
    map_data[:red] = { latlon: red.latlon, popup: "#{link_to(red, red)}" } if red.present? && red.positioned?
    markers = options.delete(:markers)
    if markers.present?
      map_data[:markers] = markers.select(&:positioned?).map do |marker|
        marker_hash = {}
        marker_hash = block.call(marker) if block.present?
        { latlon: marker.latlon, popup: "#{link_to(marker, marker)}" }.merge(marker_hash)
      end
    end
    data = options.delete(:data) || {}
    data[:map] = map_data.to_json
    content_tag(:div, "", class: html_classes, id: id, data: data)
  end
end