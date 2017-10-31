class BLA::BadgesController < ResourceController
  resource_actions :index, cache: %i[index]
end
