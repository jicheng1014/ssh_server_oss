import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["output", "button", "status", "formatSelect"]
  static values = { 
    serverId: Number
  }

  connect() {
    this.isLoading = false
  }

  async fetch() {
    if (this.isLoading) return
    
    this.isLoading = true
    this.updateButtonState(true)
    
    try {
      const format = this.hasFormatSelectTarget ? this.formatSelectTarget.value : "aux"
      this.updateStatus("获取中...")
      
      const response = await fetch(`/servers/${this.serverIdValue}/ps?format=${format}`, {
        headers: {
          "Accept": "application/json",
          "X-Requested-With": "XMLHttpRequest"
        }
      })
      
      const data = await response.json()
      
      if (data.success) {
        this.outputTarget.textContent = data.output || "无输出"
        const timestamp = data.timestamp ? new Date(data.timestamp).toLocaleTimeString("zh-CN", { hour12: false }) : "未知"
        this.updateStatus(`更新时间: ${timestamp}`)
      } else {
        this.outputTarget.textContent = `错误: ${data.error}`
        this.updateStatus("获取失败")
      }
    } catch (error) {
      this.outputTarget.textContent = `请求失败: ${error.message}`
      this.updateStatus("请求失败")
    } finally {
      this.isLoading = false
      this.updateButtonState(false)
    }
  }

  updateButtonState(loading) {
    if (this.hasButtonTarget) {
      if (loading) {
        this.buttonTarget.disabled = true
        this.buttonTarget.textContent = "获取中..."
        this.buttonTarget.classList.add("opacity-50", "cursor-not-allowed")
      } else {
        this.buttonTarget.disabled = false
        this.buttonTarget.textContent = "查看进程"
        this.buttonTarget.classList.remove("opacity-50", "cursor-not-allowed")
      }
    }
  }

  updateStatus(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
    }
  }
}
