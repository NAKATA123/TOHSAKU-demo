import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    const tab = new URLSearchParams(window.location.search).get("tab")
    if (tab) this.activate(tab)
  }

  switch(event) {
    this.activate(event.currentTarget.dataset.tab)
  }

  activate(selectedTab) {
    this.tabTargets.forEach((tab) => tab.classList.toggle("active", tab.dataset.tab === selectedTab))
    this.panelTargets.forEach((panel) => panel.classList.toggle("active", panel.dataset.panel === selectedTab))
  }
}
