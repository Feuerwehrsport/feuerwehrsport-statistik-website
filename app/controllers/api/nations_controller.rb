module API
  class NationsController < BaseController
    include CRUD::ShowAction
    include CRUD::IndexAction
  end
end
