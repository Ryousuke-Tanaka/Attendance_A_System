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
  def working_times(started_at, finished_at, spread_day)
    @attendance = Attendance.find(params[:id])
    @attendance.spread_day = spread_day
    if @attendance.spread_day
      format("%.2f",(((finished_at - started_at) / 60) / 60.0) + 24)  # 日跨ぎ勤務
    else
      format("%.2f",(((finished_at - started_at) / 60) / 60.0)) # 日跨ぎ無しで勤務
    end
  end
  
  # 時間を15分刻みで表示
  def set_minutes(time)
    format("%.2d", time.floor_to(15.minutes).min)
  end
  
  # 残業時間を計算
  def overtime_calculation(finished_at, spread_day, designated_work_end_time)
    @attendance = Attendance.find(params[:id])
    @attendance.spread_day = spread_day
    if @attendance.spread_day
      format("%.2f",(((finished_at - designated_work_end_time) / 60) / 60.0))
    else
      if (finished_at - designated_work_end_time) < 0
        flash[:danger] = "残業時間がマイナスです。"
        redirect_to user_url
      else
        format("%.2f",(((finished_at - designated_work_end_time) / 60) / 60.0) - 24)
      end
    end
  end
  
end
