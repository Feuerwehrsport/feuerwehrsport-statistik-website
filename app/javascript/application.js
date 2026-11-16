import { Turbo } from "@hotwired/turbo-rails"
import "controllers"

// Turbo Drive stays off until the old jQuery initialisation (M3.ready) is replaced.
// Turbo Frames still work for elements with data-turbo="true" (e.g. the contribution dialog).
Turbo.session.drive = false
