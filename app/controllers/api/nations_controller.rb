class API::NationsController < API::BaseController
  include API::CRUD::ShowAction
  include API::CRUD::IndexAction
end