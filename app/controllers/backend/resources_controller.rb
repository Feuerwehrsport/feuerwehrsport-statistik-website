module Backend
  class ResourcesController < BackendController
    include CRUDActions
    include ChangeLogSupport

    def self.models
      [
        AdminUser,
        Competition,
        Event,
        GroupScore,
        GroupScoreCategory,
        GroupScoreType,
        Link,
        Nation,
        News,
        Person,
        PersonParticipation,
        Place,
        Score,
        ScoreType,
        Team,
      ]
    end

    helper_method def index_columns(resource_class)
      resource_class.new.try(:decorate).try(:index_columns) || [:id, :to_s]
    end
  end
end