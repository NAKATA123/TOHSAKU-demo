module ApplicationHelper
  def period_label(period)
    period == "am" ? "午前" : "午後"
  end

  # 今年の日付なら年を省略、それ以外の年なら年も表示する
  def smart_date(date, with_year: "%Y/%m/%d", without_year: "%m/%d")
    date.strftime(date.year == Time.zone.today.year ? without_year : with_year)
  end
end
