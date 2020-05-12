require 'csv'

csv1 = CSV.generate do |csv|
  column_names = %w(worked_on "曜日" started_at finished_at "在社時間")
  csv << column_names
  @attendances.each do |day|
  column_values = [
    l(day.worked_on, format: :short),
    $days_of_the_week[day.worked_on.wday],
    if day.started_at.present?
      day.started_at.floor_to(15.minutes)
    end,
    if day.finished_at.present?
      l(day.finished_at.floor_to(15.minutes), format: :time)
    end,
    if day.started_at.present? && day.finished_at.present?
      working_times(day.started_at.floor_to(15.minutes), day.finished_at.floor_to(15.minutes), day.spread_day)
    end
  ]
    csv << column_values
  end
end
