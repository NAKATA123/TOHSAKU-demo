module ApplicationHelper
  def period_label(period)
    period == "am" ? "午前" : "午後"
  end
end
