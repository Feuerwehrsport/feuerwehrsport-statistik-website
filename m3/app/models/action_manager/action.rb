# frozen_string_literal: true

ActionManager::Action = Struct.new(:name, :resource_or_class, :ability, :controller) do
  include Draper::Decoratable
  attr_accessor :url

  def link_to?
    can?(name, resource_or_class)
  end

  def redirect_to?
    link_to?
  end

  def decorator_class
    controller_name = controller.class.name.gsub(/Controller\Z/, '').gsub('::', '')
    begin
      "ActionManager::#{controller_name}#{name.to_s.camelcase}ActionDecorator".constantize
    rescue NameError
      begin
        "ActionManager::#{name.to_s.camelcase}ActionDecorator".constantize
      rescue NameError
        super
      end
    end
  end

  protected

  def can?(*args)
    ability.can?(*args)
  end
end
