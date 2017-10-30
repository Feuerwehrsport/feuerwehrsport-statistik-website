class NewsArticlesController < ResourceController
  resource_actions :show, :index, cache: %i[show index]
end
