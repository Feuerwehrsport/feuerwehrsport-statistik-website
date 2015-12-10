module AutoDecorate
  def render(*args)
    auto_decorate
    super
  end

  private

  def auto_decorate
    if resource_instance
      begin
        self.resource_instance = resource_instance.decorate if resource_instance.respond_to? :decorate
      rescue Draper::UninferrableDecoratorError => e
      end
    end
    if resource_collection
      begin
        self.resource_collection = resource_collection.decorate
      rescue Draper::UninferrableDecoratorError => e
      end
    end
  end
end