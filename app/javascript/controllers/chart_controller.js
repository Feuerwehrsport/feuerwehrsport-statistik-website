import { Controller } from "@hotwired/stimulus"
import "chart.js" // UMD build, sets window.Chart

const INK = "#14202B"
const MUTED = "#56626F"
const LINE = "#E1E4E9"

const formatNumber = (value, digits = 0) =>
  value.toLocaleString("de-DE", { minimumFractionDigits: digits, maximumFractionDigits: digits })

let defaultsApplied = false
function applyDefaults(Chart) {
  if (defaultsApplied) return
  defaultsApplied = true

  const d = Chart.defaults
  d.locale = "de-DE"
  d.animation = false
  d.maintainAspectRatio = false
  d.font.family = "Inter, system-ui, sans-serif"
  d.font.size = 12
  d.color = MUTED
  d.borderColor = LINE

  d.plugins.legend.position = "bottom"
  d.plugins.legend.labels.usePointStyle = true
  d.plugins.legend.labels.boxWidth = 8
  d.plugins.legend.labels.boxHeight = 8
  d.plugins.legend.labels.color = INK

  Object.assign(d.plugins.tooltip, {
    backgroundColor: INK,
    padding: 10,
    cornerRadius: 8,
    boxPadding: 4,
    usePointStyle: true,
    titleFont: { weight: "600" },
  })

  d.elements.line.borderWidth = 2
  d.elements.point.radius = 2.5
  d.elements.point.hoverRadius = 5
  d.elements.point.hitRadius = 8
  d.elements.bar.borderRadius = 4
  d.elements.arc.borderColor = "#FFFFFF"
  d.elements.arc.borderWidth = 2

  d.datasets.bar.maxBarThickness = 14
  d.datasets.doughnut.cutout = "62%"
}

// shared axis styling: recessive grid, no axis lines
function styleScales(config) {
  if (config.type === "doughnut") return
  const options = config.options
  const valueAxis = options.indexAxis === "y" ? "x" : "y"
  const categoryAxis = valueAxis === "x" ? "y" : "x"
  options.scales ??= {}
  options.scales[valueAxis] = {
    beginAtZero: config.type === "bar",
    grid: { color: LINE },
    border: { display: false },
    ...options.scales[valueAxis],
  }
  options.scales[categoryAxis] = {
    grid: { display: false },
    border: { color: LINE },
    // bar charts show every category (e.g. all federal states), line charts skip labels that do not fit
    ticks: { autoSkip: config.type === "line" || (config.data.labels?.length ?? 0) > 24, autoSkipPadding: 8, maxRotation: 0 },
    ...options.scales[categoryAxis],
  }
}

function applyFormat(config, format) {
  const options = config.options
  const tooltip = (options.plugins.tooltip ??= {})
  const callbacks = (tooltip.callbacks ??= {})

  // optional per point names (e.g. team name on a rank axis, competition on a date axis)
  callbacks.title = (items) => {
    const item = items[0]
    if (!item) return ""
    const name = item.dataset.names?.[item.dataIndex]
    if (format === "date") return new Date(item.parsed.x).toLocaleDateString("de-DE")
    return name ? `${name} (${item.label})` : item.label
  }

  if (config.type !== "doughnut") {
    options.interaction = { mode: "index", intersect: false }
  }

  // legend shows short line pieces, so dashed series stay recognisable
  if (config.type === "line") {
    options.plugins.legend = {
      ...options.plugins.legend,
      labels: {
        usePointStyle: false,
        boxWidth: 22,
        boxHeight: 0,
        generateLabels: (chart) =>
          window.Chart.defaults.plugins.legend.labels
            .generateLabels(chart)
            .map((label) => ({ ...label, fillStyle: "transparent", lineWidth: 2 })),
      },
    }
  }

  if (format === "seconds") {
    options.scales.y.ticks = { callback: (value) => `${formatNumber(value)} s` }
    callbacks.label = (item) =>
      item.parsed.y == null ? null : `${item.dataset.label}: ${formatNumber(item.parsed.y, 2)} s`
  } else if (format === "date") {
    options.scales.x = {
      ...options.scales.x,
      type: "linear",
      ticks: { autoSkip: true, autoSkipPadding: 12, maxRotation: 0, callback: (value) => new Date(value).getFullYear() },
      // one tick at the start of every year
      afterBuildTicks: (axis) => {
        const ticks = []
        for (let year = new Date(axis.min).getFullYear() + 1; year <= new Date(axis.max).getFullYear(); year++) {
          ticks.push({ value: new Date(year, 0, 1).getTime() })
        }
        axis.ticks = ticks
      },
    }
  }

  if (config.type === "doughnut") {
    const percent = (chart, index) => {
      const values = chart.data.datasets[0].data
      const total = values.reduce((sum, value) => sum + value, 0)
      return total ? formatNumber((values[index] * 100) / total, 1) : "0"
    }
    options.plugins.legend = {
      position: "right",
      ...options.plugins.legend,
      labels: {
        generateLabels: (chart) =>
          window.Chart.overrides.doughnut.plugins.legend.labels
            .generateLabels(chart)
            .map((label) => ({ ...label, text: `${label.text} – ${percent(chart, label.index)} %` })),
      },
    }
    callbacks.title = (items) => items[0]?.dataset.label ?? ""
    callbacks.label = (item) =>
      `${item.label}: ${formatNumber(item.parsed)} (${percent(item.chart, item.dataIndex)} %)`
  }
}

// Renders a Chart.js configuration built by Chart::Base (Ruby)
export default class extends Controller {
  static values = { config: Object }

  connect() {
    const Chart = window.Chart
    applyDefaults(Chart)

    const { format, ...config } = structuredClone(this.configValue)
    config.options ??= {}
    config.options.plugins ??= {}
    styleScales(config)
    applyFormat(config, format)
    this.chart = new Chart(this.element, config)
  }

  disconnect() {
    this.chart?.destroy()
    this.chart = null
  }
}
