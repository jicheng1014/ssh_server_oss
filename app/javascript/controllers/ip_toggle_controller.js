import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["ip", "button"]
  static values = { hidden: { type: Boolean, default: false } }

  toggle() {
    this.hiddenValue = !this.hiddenValue
    this.updateDisplay()
  }

  updateDisplay() {
    this.ipTargets.forEach(el => {
      const fullIp = el.dataset.fullIp
      const maskedIp = el.dataset.maskedIp
      el.textContent = this.hiddenValue ? maskedIp : fullIp
    })

    this.buttonTarget.textContent = this.hiddenValue ? "显示IP" : "隐藏IP"
  }
}
