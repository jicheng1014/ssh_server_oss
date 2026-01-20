import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "spinner"]
  static values = { url: String }

  async refresh() {
    this.buttonTarget.disabled = true
    this.spinnerTarget.classList.remove("hidden")

    try {
      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Accept": "text/vnd.turbo-stream.html"
        }
      })

      if (!response.ok) {
        throw new Error("刷新失败")
      }
    } catch (error) {
      console.error(error)
      alert("刷新失败，请重试")
    } finally {
      this.buttonTarget.disabled = false
      this.spinnerTarget.classList.add("hidden")
    }
  }
}
