import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["displayArea", "editArea", "toggleButton"]

  toggleEdit() {
    this.displayAreaTarget.classList.add("hidden")
    this.editAreaTarget.classList.remove("hidden")
    this.toggleButtonTarget.classList.add("hidden")
  }

  cancelEdit() {
    this.displayAreaTarget.classList.remove("hidden")
    this.editAreaTarget.classList.add("hidden")
    this.toggleButtonTarget.classList.remove("hidden")
  }
}
