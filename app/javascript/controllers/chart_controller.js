import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    type: String,
    data: Object,
    options: Object
  }

  connect() {
    // 等待 Chart.js 加载完成
    if (typeof Chart === 'undefined') {
      console.error("Chart.js 未加载")
      return
    }

    try {
      const ctx = this.element.getContext("2d")
      
      // 解析数据
      const chartData = typeof this.dataValue === 'string' 
        ? JSON.parse(this.dataValue) 
        : this.dataValue
      
      // 解析选项
      const chartOptions = typeof this.optionsValue === 'string'
        ? JSON.parse(this.optionsValue)
        : (this.optionsValue || {})
      
      // 合并默认选项
      const defaultOptions = {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'bottom'
          },
          tooltip: {
            callbacks: {
              label: (context) => {
                return `${context.label}: ${context.parsed} 台`
              }
            }
          }
        }
      }
      
      const finalOptions = {
        ...defaultOptions,
        ...chartOptions
      }
      
      this.chart = new Chart(ctx, {
        type: this.typeValue,
        data: chartData,
        options: finalOptions
      })
    } catch (error) {
      console.error("图表初始化失败:", error)
      console.error("数据:", this.dataValue)
      console.error("选项:", this.optionsValue)
    }
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
      this.chart = null
    }
  }
}
