# frozen_string_literal: true

require 'rails_helper'
require 'cancan/matchers'

describe Ability do
  subject(:ability) { described_class.new(user, nil) }

  let(:public_read_classes) do
    [
      Bla::Badge, Competition, ChangeLog, Event, GroupScoreCategory, GroupScoreType, GroupScore, Nation, Person,
      PersonSpelling, Place, Score, ScoreType, SingleDiscipline, Team, TeamMember, TeamSpelling, Year,
      Series::TeamAssessment, Series::PersonAssessment, Series::Cup, Series::TeamParticipation,
      Series::PersonParticipation, Series::Round, Series::Kind
    ]
  end
  let(:series_classes) do
    [
      Series::TeamAssessment, Series::PersonAssessment, Series::Cup, Series::TeamParticipation,
      Series::PersonParticipation, Series::Round
    ]
  end
  let(:sub_admin_classes) do
    [
      Caching::Cleaner, ChangeRequest, Competition, CompetitionFile, Event, GroupScore, GroupScoreCategory,
      GroupScoreType, Import::Scores, ImportRequest, ImportRequestFile, Link, M3::Asset, M3::ImageAsset, Nation,
      People::Cleaner, Person, PersonParticipation, PersonSpelling, Place, Repairs::TeamScoreMove, Score, ScoreType,
      Team, TeamSpelling
    ]
  end

  shared_examples 'basic abilities' do
    it 'can read public data' do
      public_read_classes.each do |klass|
        expect(ability).to be_able_to(:read, klass), "expected to read #{klass}"
      end
      expect(ability).to be_able_to(:best_performance, Year)
      expect(ability).to be_able_to(:best_scores, Year)
    end

    it 'can use login and api user functions' do
      expect(ability).to be_able_to(:create, ApiUser)
      expect(ability).to be_able_to(:status, ApiUser)
      expect(ability).to be_able_to(:logout, ApiUser)
      expect(ability).to be_able_to(:create, AdminUsers::Registration)
    end
  end

  shared_examples 'no series management' do
    it 'can not change series' do
      actions = %i[create update destroy]
      series_classes.each do |klass|
        actions.each do |action|
          expect(ability).not_to be_able_to(action, klass), "expected not to #{action} #{klass}"
        end
      end
      expect(ability).not_to be_able_to(:create, Series::Kind)
    end
  end

  context 'without user' do
    let(:user) { nil }

    it_behaves_like 'basic abilities'
    it_behaves_like 'no series management'

    it 'can not write anything' do
      expect(ability).not_to be_able_to(:create, ChangeRequest)
      expect(ability).not_to be_able_to(:create, ImportRequest)
      expect(ability).not_to be_able_to(:update, Score)
      expect(ability).not_to be_able_to(:create, Person)
      expect(ability).not_to be_able_to(:show, AdminUser)
      expect(ability).not_to be_able_to(:manage, Caching::Cleaner)
      expect(ability).not_to be_able_to(:index, UncheckedTeam)
    end
  end

  context 'with api user' do
    let(:user) { build_stubbed(:api_user) }

    it_behaves_like 'basic abilities'
    it_behaves_like 'no series management'

    it 'can do api write actions' do
      expect(ability).to be_able_to(:create, ChangeRequest)
      expect(ability).to be_able_to(:create, CompetitionFile)
      expect(ability).to be_able_to(:create, Link)
      expect(ability).to be_able_to(:show, Link)
      expect(ability).to be_able_to(:create, Person)
      expect(ability).to be_able_to(:update, Place)
      expect(ability).to be_able_to(:update, Score)
      expect(ability).to be_able_to(:create, Team)
      expect(ability).to be_able_to(:update, Team)
      expect(ability).to be_able_to(:person_participation, GroupScore)
      expect(ability).to be_able_to(:create, ImportRequest)
    end

    it 'can not check teams' do
      expect(ability).not_to be_able_to(:update, UncheckedTeam.new)
    end

    it 'can not do admin actions' do
      expect(ability).not_to be_able_to(:update, Person)
      expect(ability).not_to be_able_to(:destroy, Team)
      expect(ability).not_to be_able_to(:destroy, Score)
      expect(ability).not_to be_able_to(:update, ChangeRequest)
      expect(ability).not_to be_able_to(:index, ImportRequest)
      expect(ability).not_to be_able_to(:show, ImportRequest.new)
      expect(ability).not_to be_able_to(:show, AdminUser)
      expect(ability).not_to be_able_to(:manage, Caching::Cleaner)
    end
  end

  context 'with user' do
    let(:user) { build_stubbed(:admin_user, :user) }
    let(:other_user) { build_stubbed(:admin_user, :admin) }

    it_behaves_like 'basic abilities'
    it_behaves_like 'no series management'

    it 'inherits api abilities' do
      expect(ability).to be_able_to(:create, ChangeRequest)
      expect(ability).to be_able_to(:update, Score)
      expect(ability).to be_able_to(:create, Team)
    end

    it 'can not check teams' do
      expect(ability).to be_able_to(:update, Team.new)
      expect(ability).not_to be_able_to(:index, UncheckedTeam)
      expect(ability).not_to be_able_to(:update, UncheckedTeam.new)
    end

    it 'lists own import requests only' do
      own = create(:import_request, admin_user: create(:admin_user, :user))
      create(:import_request, admin_user: create(:admin_user, :admin))
      own_ability = described_class.new(own.admin_user, nil)
      expect(ImportRequest.accessible_by(own_ability, :index)).to eq [own]
    end

    it 'can manage own import requests only' do
      expect(ability).to be_able_to(:create, ImportRequest)
      expect(ability).to be_able_to(:index, ImportRequest)
      expect(ability).to be_able_to(:show, ImportRequest.new(admin_user_id: user.id))
      expect(ability).not_to be_able_to(:show, ImportRequest.new(admin_user_id: other_user.id))
      expect(ability).not_to be_able_to(:update, ImportRequest.new(admin_user_id: user.id))
      expect(ability).not_to be_able_to(:destroy, ImportRequest.new(admin_user_id: user.id))
    end

    it 'can manage own admin user account only' do
      %i[logout show update].each do |action|
        expect(ability).to be_able_to(action, user)
        expect(ability).not_to be_able_to(action, other_user)
      end
      expect(ability).not_to be_able_to(:destroy, user)
    end

    it 'can not do admin actions' do
      expect(ability).not_to be_able_to(:update, Person)
      expect(ability).not_to be_able_to(:destroy, Competition)
      expect(ability).not_to be_able_to(:update, ChangeRequest)
      expect(ability).not_to be_able_to(:manage, Caching::Cleaner)
    end
  end

  context 'with sub_admin' do
    let(:user) { build_stubbed(:admin_user, :sub_admin) }

    it_behaves_like 'basic abilities'
    it_behaves_like 'no series management'

    it 'can manage competition data' do
      sub_admin_classes.each do |klass|
        expect(ability).to be_able_to(:manage, klass), "expected to manage #{klass}"
      end
    end

    it 'can check teams' do
      expect(ability).to be_able_to(:index, UncheckedTeam)
      expect(ability).to be_able_to(:update, UncheckedTeam.new)
    end

    it 'can manage all import requests' do
      expect(ability).to be_able_to(:update, ImportRequest.new(admin_user_id: user.id + 1))
      expect(ability).to be_able_to(:destroy, ImportRequest.new(admin_user_id: user.id + 1))
    end

    it 'can not manage admin users and api users' do
      expect(ability).to be_able_to(:show, user)
      expect(ability).not_to be_able_to(:show, AdminUser.new(id: user.id + 1))
      expect(ability).not_to be_able_to(:index, AdminUser)
      expect(ability).not_to be_able_to(:destroy, AdminUser)
      expect(ability).not_to be_able_to(:index, ApiUser)
      expect(ability).not_to be_able_to(:manage, :all)
    end
  end

  context 'with sub_admin_with_series' do
    let(:user) { build_stubbed(:admin_user, :sub_admin, role: :sub_admin_with_series) }

    it_behaves_like 'basic abilities'

    it 'has all sub_admin abilities' do
      sub_admin_classes.each do |klass|
        expect(ability).to be_able_to(:manage, klass), "expected to manage #{klass}"
      end
    end

    it 'can manage series' do
      series_classes.each do |klass|
        expect(ability).to be_able_to(:manage, klass), "expected to manage #{klass}"
      end
    end

    it 'can only read series kinds' do
      expect(ability).to be_able_to(:read, Series::Kind)
      expect(ability).not_to be_able_to(:create, Series::Kind)
    end

    it 'can not manage admin users' do
      expect(ability).not_to be_able_to(:index, AdminUser)
      expect(ability).not_to be_able_to(:manage, :all)
    end
  end

  context 'with admin' do
    let(:user) { build_stubbed(:admin_user, :admin) }

    it_behaves_like 'basic abilities'

    it 'can manage everything' do
      expect(ability).to be_able_to(:manage, :all)
      (sub_admin_classes + series_classes + [AdminUser, ApiUser, Series::Kind]).each do |klass|
        expect(ability).to be_able_to(:manage, klass), "expected to manage #{klass}"
      end
    end
  end

  context 'with unknown role' do
    let(:user) { AdminUser.new(role: :foobar) }

    it_behaves_like 'basic abilities'
    it_behaves_like 'no series management'

    it 'gets only basic abilities' do
      expect(ability).not_to be_able_to(:create, ChangeRequest)
      expect(ability).not_to be_able_to(:create, ImportRequest)
    end
  end
end
