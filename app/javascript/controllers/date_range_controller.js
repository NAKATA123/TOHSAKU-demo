import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "startDate", "endDate"]
  static values = { holidays: Array }

  connect() {
    const start = this.startDateTarget.value
    const end   = this.endDateTarget.value
    const defaultDate = (start && end) ? [start, end] : (start ? [start] : [])
    const holidays = new Set(this.holidaysValue)

    this.fp = flatpickr(this.displayTarget, {
      mode: "range",
      locale: "ja",
      dateFormat: "Y/m/d",
      defaultDate,
      disableMobile: true,
      onDayCreate: (dObj, dStr, fp, dayElem) => {
        const date = dayElem.dateObj
        const isWeekend = date.getDay() === 0 || date.getDay() === 6
        if (isWeekend || holidays.has(this.toISO(date))) {
          dayElem.classList.add("jp-weekend")
        }
      },
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
