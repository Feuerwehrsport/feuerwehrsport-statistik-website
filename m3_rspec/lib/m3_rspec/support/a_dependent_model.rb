# frozen_string_literal: true

# Scans database for foreign keys and checks if an association with dependent option is set.
#
# If the association is scoped it is treated like non-existing and should be completed by an unscoped variant or by
# ignoring the foreign key explicitly:
#
#   it_behaves_like 'a dependent model', ignore: %w(chapters.book_id)
#
shared_examples 'a dependent model' do |options = {}|
  it 'has a dependent option for has_* associations' do
    foreign_keys = foreign_keys(described_class.table_name)
    associations = safe_associations(described_class)
    ignore = options[:ignore] || []

    suspicious_keys =
      foreign_keys.map { |key| "#{key.from_table}.#{key.column}" } -
      associations.map { |assoc| "#{assoc.klass.table_name}.#{assoc.foreign_key}" } -
      ignore

    expect(suspicious_keys).to be_empty, -> {
      "Missing or incomplete foreign key configuration for #{suspicious_keys.to_sentence(locale: :en)}\n" \
        "To ignore those keys add the following to the spec:\n  " \
        "ignore: %w(#{suspicious_keys.join(' ')})"
    }
  end

  def foreign_keys(to_table)
    ActiveRecord::Base.connection.tables.map do |table_name|
      ActiveRecord::Base.connection.foreign_keys(table_name).select { |index| index.to_table == to_table }
    end.flatten
  end

  def safe_associations(target_class)
    associations =
      target_class.reflect_on_all_associations(:has_many) +
      target_class.reflect_on_all_associations(:has_one)
    associations.select { |assoc| assoc.options[:dependent].in?(%i[destroy nullify]) && assoc.scope.nil? }
  end
end
