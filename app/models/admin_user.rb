class AdminUser < ActiveRecord::Base
  ROLES = [
    :user,
    :sub_admin,
    :admin
  ]
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :confirmable, :lockable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :news, dependent: :restrict_with_exception

  validates :name, presence: true
  validates :role, inclusion: { in: ROLES }

  def role
    super.try(:to_sym)
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
end
