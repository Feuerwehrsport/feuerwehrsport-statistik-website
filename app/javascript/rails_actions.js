// Replacement for the two features of jquery_ujs that are still used:
// - data-confirm on links, buttons and forms: asks before the action
// - data-method on links (link_to ..., method: :delete): submits a normal form with _method and CSRF token
// Forms are submitted without Turbo (see Turbo.config.forms.mode = "optin"), so the backend may render pages with
// status 200 (e.g. the destroy confirmation).

function confirmed(element) {
  const message = element?.getAttribute("data-confirm")
  return !message || window.confirm(message)
}

function submitWithMethod(link) {
  const form = document.createElement("form")
  form.method = "post"
  form.action = link.href
  form.hidden = true
  form.dataset.turbo = "false"

  const addField = (name, value) => {
    const input = document.createElement("input")
    input.type = "hidden"
    input.name = name
    input.value = value
    form.append(input)
  }
  addField("_method", link.dataset.method)
  const param = document.querySelector('meta[name="csrf-param"]')?.content
  const token = document.querySelector('meta[name="csrf-token"]')?.content
  if (param && token) addField(param, token)

  document.body.append(form)
  form.submit()
}

// capture phase: runs before Turbo and the Stimulus controllers
document.addEventListener("click", (event) => {
  const element = event.target.closest("a[data-confirm], a[data-method], button[data-confirm], input[data-confirm]")
  if (!element || event.defaultPrevented) return
  // buttons are checked on submit (includes submitting with the keyboard)
  if (element.form && element.type === "submit") return

  if (!confirmed(element)) {
    event.preventDefault()
    event.stopImmediatePropagation()
    return
  }

  const method = element.dataset.method?.toLowerCase()
  if (element.tagName === "A" && method && method !== "get") {
    event.preventDefault()
    event.stopImmediatePropagation()
    submitWithMethod(element)
  }
}, true)

document.addEventListener("submit", (event) => {
  const form = event.target
  if (!confirmed(event.submitter) || !confirmed(form)) {
    event.preventDefault()
    event.stopImmediatePropagation()
  }
}, true)
