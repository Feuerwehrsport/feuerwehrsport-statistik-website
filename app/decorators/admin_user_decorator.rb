class AdminUserDecorator < AppDecorator
  def to_s
    name
  end

  def name_with_role
    "#{role}: #{name}"
  end
end
