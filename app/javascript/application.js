import { Turbo } from "@hotwired/turbo-rails"
import "controllers"
import "rails_actions"

// Turbo Drive for links. Forms are only submitted by Turbo inside data-turbo="true" (e.g. the dialogs),
// all other forms keep their normal behaviour (the backend renders errors with status 200).
Turbo.config.forms.mode = "optin"
