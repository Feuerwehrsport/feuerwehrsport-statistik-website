# Feuerwehrsport-Statistik

Rails-Anwendung hinter [feuerwehrsport-statistik.de](https://feuerwehrsport-statistik.de/) – der Ergebnisdatenbank
für den Feuerwehrsport in Deutschland.

## Was die Webseite bietet

- **Ergebnisse** aus Wettkämpfen seit vielen Jahren in den Disziplinen Hakenleitersteigen, 100-Meter-Hindernisbahn,
  Zweikampf, Gruppenstafette, 4x100-Meter-Feuerwehrstafette und Löschangriff Nass
- **Personen, Mannschaften, Wettkämpfe, Wettkampforte und -typen** mit Bestzeiten, Statistiken und Diagrammen
- **Jahresübersichten**, Bestleistungen, Rekorde und Verbesserungen
- **Wettkampfserien** (Cups) mit Wertungen und PDF-Export
- **Bundesleistungsabzeichen** mit Auswertung
- **Mitmachen:** Besucher können Fehler melden, Daten ergänzen (Änderungsanfragen) und Ergebnisse zum Import einreichen
  (Import-Anfragen); ein Backend für Administratoren verarbeitet diese
- **JSON-API** unter `/api`, die auch die Formulare der Webseite nutzen

## Geschichte

- Beginn der Entwicklung: September 2015
- Erste Preview-Version in PHP: 25. Oktober 2015 ([altes PHP-Projekt](https://github.com/georf/feuerwehrsport-statistik))
- Umstellung auf Rails: 20. Januar 2016
- Aktuell: Rails 8.1 auf Ruby 4.0

## Technik

- Ruby (Version in `mise.toml`) und Rails 8.1
- PostgreSQL, einige Auswertungen als SQL-Views (`app/models/*.sql`, angelegt über `activerecord_views`)
- Hintergrundjobs mit Solid Queue, Übersicht unter `/admin-jobs` (nur für Admins)
- Oberfläche: HAML, Sprockets mit CoffeeScript und Sass, Bootstrap 3, jQuery, DataTables, Highcharts
- Tests mit RSpec (Request-, Model- und Feature-Specs mit Cuprite/Chrome)
- Deployment mit Capistrano (`capistrano3_featureset`)

## Entwicklungsumgebung einrichten

### Voraussetzungen

- [mise](https://mise.jdx.dev/) für die Ruby-Version
- PostgreSQL
- ImageMagick und die PostgreSQL-Entwicklerdateien, z. B. unter Debian/Ubuntu:
  `sudo apt-get install imagemagick libpq-dev`
- Chrome oder Chromium für die Feature-Specs

### Installation

```sh
mise install                 # Ruby aus mise.toml installieren
bundle install
```

Die Datenbank-Zugangsdaten für Entwicklung und Tests stehen in `config/database.yml`
(Benutzer und Passwort jeweils `feuerwehrsport-statistik`, Datenbank `feuerwehrsport-statistik` bzw.
`feuerwehrsport-statistik-test`). Den Benutzer einmalig anlegen:

```sh
sudo -u postgres createuser --createdb --pwprompt feuerwehrsport-statistik
bin/rails db:prepare         # Datenbank anlegen und Schema laden
```

Einen Admin für das lokale Backend anlegen:

```sh
bin/rails runner 'AdminUser.create!(role: :admin, login_attributes: { name: "Admin", email_address: "admin@example.com",
  password: "geheim123", password_confirmation: "geheim123", verified_at: Time.current })'
```

### Starten

```sh
bin/rails server
```

Die Anwendung läuft unter [http://localhost:5060](http://localhost:5060). Andere Hostnamen werden auf diese Adresse
umgeleitet. In der Entwicklung läuft Solid Queue im Puma-Prozess mit, ein separater Job-Prozess ist nicht nötig
(in Produktion: `bin/jobs`). Mails werden in der Entwicklung als Dateien unter `tmp/mails` abgelegt.

## Tests und Qualität

```sh
bundle exec rspec            # alle Specs
CI=1 bundle exec rspec       # mit eager loading wie in der CI
bundle exec rubocop
bin/bundler-audit            # bekannte Sicherheitslücken in Gems
bundle exec ruby-audit check # bekannte Sicherheitslücken in Ruby und RubyGems
bin/brakeman                 # statische Sicherheitsanalyse
```

Mehrere Testläufe parallel brauchen getrennte Datenbanken: Mit `TEST_ENV_NUMBER=2` wird
`feuerwehrsport-statistik-test2` verwendet (vorher `RAILS_ENV=test TEST_ENV_NUMBER=2 bin/rails db:create db:schema:load`).

GitHub Actions führt RuboCop, bundler-audit und RSpec bei jedem Push aus (`.github/workflows/ci.yml`) und prüft
zusätzlich täglich auf neue Sicherheitslücken (`.github/workflows/security.yml`).

## Deployment

```sh
bundle exec cap production deploy
```

Der Server nutzt mise mit derselben Ruby-Version wie `mise.toml`; `cap production version_manager:check` prüft das.

---

Unterstützt von [Lichtbit](https://lichtbit.com)
