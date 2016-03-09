class Series::RoundSerializer < ActiveModel::Serializer
  attributes :id, :name, :year, :aggregate_type
end
