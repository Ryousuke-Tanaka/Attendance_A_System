require 'csv'

bom = "\uFEFF"
CSV.generate(bom) do |csv|
  column_names = %w(日付 曜日 出社時間 退社時間 在社時間)
  csv << column_names
  @attendances.each do |day|
  column_values = [
    l(day.worked_on, format: :short),
    $days_of_the_week[day.worked_on.wday],
    if day.started_at.present?
      l(day.started_at.floor_to(15.minutes), format: :time)
    elsif day.after_started_at.present? && day.edit_attendance_request_status == "承認"
      l(day.after_started_at.floor_to(15.minutes), format: :time)
    end,
    if day.finished_at.present?
      l(day.finished_at.floor_to(15.minutes), format: :time)
    elsif day.after_finished_at.present? && day.edit_attendance_request_status == "承認"
      l(day.after_finished_at.floor_to(15.minutes), format: :time)
    end,
    if day.started_at.present? && day.finished_at.present?
      working_times(day.started_at.floor_to(15.minutes), day.finished_at.floor_to(15.minutes), day.spread_day)
    elsif day.after_finished_at.present? && day.after_finished_at.present? && day.edit_attendance_request_status == "承認"
      working_times(day.after_started_at.floor_to(15.minutes), day.after_finished_at.floor_to(15.minutes), day.spread_day)
    end
  ]
    csv << column_values
  end
end
