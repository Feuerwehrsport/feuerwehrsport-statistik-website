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
    if collection_instance
      begin
        self.collection_instance = collection_instance.decorate
      rescue Draper::UninferrableDecoratorError => e
      end
    end
  end
end