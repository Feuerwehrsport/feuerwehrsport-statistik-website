module MapHelper
  def map(options)
    id = options.delete(:id) || 'map'
    html_classes = options.delete(:class) || 'map'
    data = {}
    red = options.delete(:red)
    data[:red] = { latlon: red.latlon, popup: "#{link_to(red, red)}" } if red.present?
    markers = options.delete(:markers)
    if markers.present?
      data[:markers] = markers.map do |marker| 
        { latlon: marker.latlon, popup: "#{link_to(marker, marker)}" }
      end
    end
    content_tag(:div, tag(:div, class: html_classes, id: id, data: { map: data.to_json }))
  end
end