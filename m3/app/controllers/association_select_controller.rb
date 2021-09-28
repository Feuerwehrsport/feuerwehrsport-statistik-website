# frozen_string_literal: true

# Allow Ajax-based association selections via configuration model
#
# == Add Route (once)
#
# Add a route to +association_select#show+
#
#   get 'association_select/:association', as: :association_select, to: 'association_select#show'
#
# == Import Stylesheets (once)
#
# Import needed stylesheets in app's stylesheets, e.g.:
#
#   @import ./association_select
#
# == Require Javascript (once)
#
# Require needed javascript, e.g.:
#
#   #= require _association_select
#
# == Create/Update AssociationSelect Model
#
# Manage associations in +app/models/association_select.rb+, e.g.:
#
#   class AssociationSelect
#     def initialize(ability)
#       @ability = ability
#     end
#
#     def companies(search_term, ids, filter: {}, limit: 10)
#       ar_relation(Company, search_term, ids, where: filter.slice(:continent), limit: limit,
#                                              search_columns: %w[companies.name])
#         .eager_load(:parent)
#         .pluck(:id, :name, 'parents_companies.name', "to_char(companies.created_at, 'DD.MM.YYYY')")
#     end
#
#     def nationalities(search_term, ids, limit: 10)
#       ar_relation(Country, search_term, ids, limit: limit, search_columns: %w[countries.name_en countries.name_de])
#         .pluck(:id, :name_de, :name_en)
#     end
#
#     def nationalities_groups
#       {
#         'Europäische Länder' =>
#           ar_relation(Country, nil, nil).where(europe: true).pluck(:id, :name_de, :name_en),
#         'Nichteuropäische Länder' =>
#           ar_relation(Country, nil, nil).where(europe: false).pluck(:id, :name_de, :name_en),
#       }
#     end
#
#     private
#
#     def ar_relation(model_class, search_term, ids, limit: nil, search_columns: [], where: nil)
#       rel = model_class.all.accessible_by(@ability, :index)
#       rel = rel.limit(limit) if limit
#       if search_term
#         where = []
#         search_columns.each do |search_column|
#           where << "#{search_column} ILIKE ?"
#         end
#         search_term = search_term.gsub(' ', '%')
#         rel = rel.where(where.join(' OR '), *(["%#{search_term}%"] * search_columns.size))
#       end
#       rel = rel.where(where) if where
#       rel = rel.where(id: ids) if ids
#       rel
#     end
#   end
#
# == Use SimpleForm Input
#
# Now you can use a SimpleForm input by specifiing the +as+ parameter:
#
#   f.association :companies, as: :association_select
#
# To show descriptions in the table of selected associations (not only the modal):
#
#   f.association :companies, as: :association_select, show_input_description: true
#
# To dynamically filter associations (see companies example above):
#
#   f.association :companies, as: :association_select, filter: { continent: 'europe' }
class AssociationSelectController < ApplicationController
  def show
    if valid?
      render json: { association: params[:association], payload: payload }
    else
      render status: :not_found, text: ''
    end
  end

  private

  def payload
    payload = {}
    payload[:results] = select.send(
      params[:association],
      params[:q].presence,
      nil,
      params.to_unsafe_h.slice(:limit).symbolize_keys,
    )
    if params[:q].blank? && select.respond_to?("#{params[:association]}_groups")
      payload[:groups] = select.send("#{params[:association]}_groups")
    end
    payload
  end

  def select
    @select ||= AssociationSelect.new(current_ability)
  end

  def valid?
    params[:association].present? && select.public_methods(false).include?(params[:association].to_sym)
  end
end
