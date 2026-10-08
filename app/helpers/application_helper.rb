module ApplicationHelper
  def period_label(period)
    period == "am" ? "午前" : "午後"
  end

  # 今年の日付なら年を省略、それ以外の年なら年も表示する
  def smart_date(date, with_year: "%Y/%m/%d", without_year: "%m/%d")
    date.strftime(date.year == Time.zone.today.year ? without_year : with_year)
  end

  # 日付選択カレンダー用：前後数年分の祝日一覧をJSで使える形で返す
  def japanese_holidays_json
    today = Time.zone.today
    HolidayJapan.between(today.prev_year, today.next_year(2)).keys.map(&:to_s).to_json
  end
end
