import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.onMove = this.onMove.bind(this)
    this.onUp = this.onUp.bind(this)
    this.row = null
  }

  dragStart(event) {
    event.preventDefault()
    this.row = event.currentTarget.closest("tr")
    this.row.classList.add("dragging")
    document.addEventListener("pointermove", this.onMove)
    document.addEventListener("pointerup", this.onUp)
  }

  onMove(event) {
    if (!this.row) return

    const overRow = document.elementFromPoint(event.clientX, event.clientY)?.closest("tr")
    if (!overRow || overRow === this.row || overRow.parentNode !== this.row.parentNode) return

    const rect = overRow.getBoundingClientRect()
    const insertAfter = event.clientY - rect.top > rect.height / 2
    overRow.parentNode.insertBefore(this.row, insertAfter ? overRow.nextSibling : overRow)
  }

  onUp() {
    document.removeEventListener("pointermove", this.onMove)
    document.removeEventListener("pointerup", this.onUp)
    if (!this.row) return

    this.row.classList.remove("dragging")
    this.save()
    this.row = null
  }

  async save() {
    const ids = Array.from(this.element.querySelectorAll("[data-id]")).map((row) => row.dataset.id)

    await fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
      },
      body: JSON.stringify({ order: ids })
    })
  }
}
