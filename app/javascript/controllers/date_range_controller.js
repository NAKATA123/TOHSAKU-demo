import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "startDate", "endDate"]

  connect() {
    const start = this.startDateTarget.value
    const end   = this.endDateTarget.value
    const defaultDate = (start && end) ? [start, end] : (start ? [start] : [])

    this.fp = flatpickr(this.displayTarget, {
      mode: "range",
      locale: "ja",
      dateFormat: "Y/m/d",
      defaultDate,
      disableMobile: true,
      onChange: (dates) => {
        if (dates.length >= 1) this.startDateTarget.value = this.toISO(dates[0])
        if (dates.length === 2) this.endDateTarget.value   = this.toISO(dates[1])
        else                    this.endDateTarget.value   = ""
      }
    })
  }

  disconnect() {
    if (this.fp) this.fp.destroy()
  }

  toISO(date) {
    const y = date.getFullYear()
    const m = String(date.getMonth() + 1).padStart(2, "0")
    const d = String(date.getDate()).padStart(2, "0")
    return `${y}-${m}-${d}`
  }
}
