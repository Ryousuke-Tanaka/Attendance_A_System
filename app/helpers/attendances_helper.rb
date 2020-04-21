module AttendancesHelper
  
  def attendance_state(attendance)
    # 受け取ったAttendanceオブジェクトが当日と一致するか評価
    if Date.current == attendance.worked_on
      return "出社" if attendance.started_at.nil?
      return "退社" if attendance.started_at.present? && attendance.finished_at.nil?
    end
    # どれにも当てはまらなかったらfalseを返す
    false
  end
  
  # 出勤時間と退勤時間を受け取り、在社時間を計算して返す
  def working_times(start, finish)
    format("%.2f",(((finish - start) / 60) / 60.0))
  end
  
  # 翌日にチェックが入っていら場合の在社時間を計算
  def spread_day_working_times(start, finish)
    format("%.2f",(((finish - start) / 60) / 60.0) + 24)
  end
  
  # 時間を15分刻みで表示
  def set_minutes(time)
    format("%.2d", time.floor_to(15.minutes).min)
  end
end
