# frozen_string_literal: true

class NewsArticlesController < ResourceController
  resource_actions :show, :index, cache: %i[show index]
end
