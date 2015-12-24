module API
  class BaseController < ApplicationController
    respond_to :json

    protected

    def current_user
      super(login_status ? :api_user : nil)
    end

    def respond_defaults
      {
        success: true,
        login: login_status,
      }
    end

    def respond_with(hash={})
      render json: handle_serializer(respond_defaults.merge(hash))
    end

    def login_status
      session[:user_id].present? && User.find_by_id(session[:user_id]).present?
    end

    def success(hash={})
      respond_with(hash)
    end

    def failed(hash={})
      respond_with({message: failed_message}.merge(hash).merge(success: false))
    end

    def failed_message
      "Something went wrong"
    end

    def handle_serializer(hash)
      hash.each do |key, value|
        hash[key] = handle_value_serializer(value)
      end
    end

    def handle_value_serializer(value)
      if value.is_a?(Draper::Decorator)
        begin
          serializer = "#{value.object.class.name}Serializer".constantize
          serializer.new(value)
        rescue NameError
          value
        end
      elsif value.is_a?(ActiveRecord::Base)
        begin
          serializer = "#{value.class.name}Serializer".constantize
          serializer.new(value)
        rescue NameError
        end
      elsif value.is_a?(Array) || value.is_a?(ApplicationCollectionDecorator)
        value.map { |e| handle_value_serializer(e) }
      elsif value.is_a?(Hash)
        handle_serializer(value)
      else
        value
      end
    end
  end
end