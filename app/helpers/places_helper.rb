module PlacesHelper
  def places_overview_hash
    other = @rows.map(&:count).select { |c| c <= 6 }.sum
    hash_array = @rows.select { |r| r.count > 6 }.map { |r| [r.name, r.count] }
    hash_array.push(["Andere", other])
    Hash[ hash_array ]
  end
end