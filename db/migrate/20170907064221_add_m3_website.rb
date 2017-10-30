class AddM3Website < ActiveRecord::Migration
  def change
    domain = Rails.env.development? ? 'localhost' : 'feuerwehrsport-statistik.de'
    name = 'Feuerwehrsport-Statistik'
    website = M3::Website.create_with(key: :fss, domain: domain, title: name, default_site: true, port: 5060).find_or_create_by!(name: name)
    website.delivery_setting.update_attributes!(website: website, delivery_method: (Rails.env.test? ? :test : :file), from_address: "no-reply@#{domain}")
  end
end
