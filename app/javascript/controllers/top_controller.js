import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["output", "button", "status"]
  static values = { 
    serverId: Number,
    interval: { type: Number, default: 2000 }
  }

  connect() {
    this.isRunning = false
    this.intervalId = null
  }

  disconnect() {
    this.stop()
  }

  toggle() {
    if (this.isRunning) {
      this.stop()
    } else {
      this.start()
    }
  }

  start() {
    if (this.isRunning) return
    
    this.isRunning = true
    this.updateButtonState(true)
    this.fetchTop()
    
    // 开始定时刷新
    this.intervalId = setInterval(() => {
      this.fetchTop()
    }, this.intervalValue)
  }

  stop() {
    if (!this.isRunning) return
    
    this.isRunning = false
    this.updateButtonState(false)
    
    if (this.intervalId) {
      clearInterval(this.intervalId)
      this.intervalId = null
    }
  }

  async fetchTop() {
    try {
      this.updateStatus("获取中...")
      const response = await fetch(`/servers/${this.serverIdValue}/top`, {
        headers: {
          "Accept": "application/json",
          "X-Requested-With": "XMLHttpRequest"
        }
      })
      
      const data = await response.json()
      
      if (data.success) {
        // 使用 textContent 保持原始格式，包括空格和换行
        this.outputTarget.textContent = data.output || "无输出"
        const timestamp = data.timestamp ? new Date(data.timestamp).toLocaleTimeString("zh-CN", { hour12: false }) : "未知"
        this.updateStatus(`更新时间: ${timestamp}`)
      } else {
        this.outputTarget.textContent = `错误: ${data.error}`
        this.updateStatus("获取失败")
        this.stop()
      }
    } catch (error) {
      this.outputTarget.textContent = `请求失败: ${error.message}`
      this.updateStatus("请求失败")
      this.stop()
    }
  }

  updateButtonState(running) {
    if (this.hasButtonTarget) {
      if (running) {
        this.buttonTarget.textContent = "停止"
        this.buttonTarget.classList.remove("bg-blue-500", "hover:bg-blue-700")
        this.buttonTarget.classList.add("bg-red-500", "hover:bg-red-700")
      } else {
        this.buttonTarget.textContent = "查看 Top"
        this.buttonTarget.classList.remove("bg-red-500", "hover:bg-red-700")
        this.buttonTarget.classList.add("bg-blue-500", "hover:bg-blue-700")
      }
    }
  }

  updateStatus(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
    }
  }
}
