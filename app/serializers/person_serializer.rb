class PersonSerializer < ActiveModel::Serializer
  attributes :id, :last_name, :first_name, :gender, :nation_id, :translated_gender
end
