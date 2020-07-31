class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month, :request_overtime, :update_overtime, :receive_overtime, :receive_change_attendance, :request_one_month,
                                  :update_change_attendance, :receive_one_month_request, :edit_log]
  before_action :logged_in_user, only: [:update, :edit_one_month, :request_overtime, :update_overtime, :receive_change_attendance, :update_change_attendance]
  before_action :correct_user, only: [:edit_one_month, :request_overtime, :update_overtime, :receive_overtime, :receive_change_attendance]
  before_action :superior_user, only: [:receive_change_attendance, :update_change_attendance, :receive_overtime, :decision_overtime]
  before_action :not_admin_user
  before_action :set_one_month, only: [:edit_one_month, :update_one_month, :request_overtime, :edit_log]
  before_action :select_superiors, only: [:edit_one_month, :update_one_month, :request_overtime, :update_overtime]
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  NO_CHECK_ERROR_MSG = "変更にチェックがないものは更新できません。"
  INVALID_ERROR_MSG = "無効な入力があった為、更新をキャンセルしました。"

  # 出退勤ボタンの勤怠登録
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end
  
  # 勤怠修正ページへ
  def edit_one_month
  end
  
  # 社員による勤怠情報修正
  def update_one_month
    ActiveRecord::Base.transaction do
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        if (item)[:after_started_at].present? && (item)[:after_finished_at].present?
          if (item)[:edit_attendance_boss].present? && (item)[:note].present?
            attendance.edit_attendance_request_status = "申請中" 
            attendance.update_attributes!(item)
          elsif attendance.edit_attendance_request_status != "承認" 
            flash[:danger] = "編集箇所には出社、退社、備考、指示者確認㊞が必要です。"
            redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
          end
        end
      end
    end
    flash[:success] = "1ヶ月分の勤怠情報を更新・申請しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = INVALID_ERROR_MSG
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  # 勤怠修正を受領
  def receive_change_attendance
    @change_attendance_requests = Attendance.order(:worked_on).where(edit_attendance_boss: @user.id, edit_attendance_request_status: "申請中").group_by(&:user_id)
  end
  
  # 上長による勤怠修正を承認・否認
  def update_change_attendance
    ActiveRecord::Base.transaction do
      change_attendance_params.each do |id, item|
        change_attendance = Attendance.find(id)
        if params[:user][:attendances][id][:change] == "true"
          if change_attendance.started_at.nil? || change_attendance.finished_at.nil?
            change_attendance.started_at = change_attendance.after_started_at
            change_attendance.finished_at = change_attendance.after_finished_at
          end
          change_attendance.update_attributes!(item)
        else
          flash[:danger] = NO_CHECK_ERROR_MSG
        end
      end
    end
    flash[:success] = "勤怠変更の決裁を更新しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid
     flash[:danger] = INVALID_ERROR_MSG
    redirect_to user_url(date: params[:date])
  end
  
  # 残業申請
  def request_overtime
    @attendance = Attendance.find_by(worked_on: params[:date])
    @attendances = @user.attendances.where(worked_on: @attendance.worked_on)
  end
  
  # 残業申請を受領
  def receive_overtime
    @overtime_requests = Attendance.order(:worked_on).where(overtime_boss: @user.id, overtime_request_status: "申請中").group_by(&:user_id)
  end
  
  # 社員が残業申請を登録 
  def update_overtime
    @user = User.find(params[:id])
    ActiveRecord::Base.transaction do
      overtime_info_params.each do |id, item|
        if params[:user][:attendances][id][:overtime_boss].present? && params[:user][:attendances][id][:job_description].present? 
          @overtime = Attendance.find(id)
          @overtime.update_attributes!(item)
        else
          flash[:danger] = "終了予定時間、業務内容、指示者確認㊞は必須です。"
          redirect_back(fallback_location: root_path) and return
        end
      end
    end
    @superior = User.find(@overtime.overtime_boss)
    flash[:success] = "#{@superior.name}に残業申請をしました。"
    redirect_back(fallback_location: root_path)
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = INVALID_ERROR_MSG
    redirect_to user_url(date: params[:date])
  end
  
  # 上長の残業申請の承認・否認
  def decision_overtime
    ActiveRecord::Base.transaction do
      decision_overtime_params.each do |id, item|
        decision_overtime = Attendance.find(id)
        if params[:user][:attendances][id][:change] == "true"
          decision_overtime.update_attributes!(item)
        else
          flash[:danger] = NO_CHECK_ERROR_MSG
        end
      end
    end
    flash[:success] = "残業申請の決裁を更新しました。"
    redirect_to user_url(current_user, date: params[:date])
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = INVALID_ERROR_MSG
    redirect_to user_url(current_user, date: params[:date])
  end
  
  # 勤怠ログ
  def edit_log
    if params[:worked_on].present?
      @approval_change_attendance_requests = Attendance.order(:worked_on).where(user_id: current_user, edit_attendance_request_status: "承認").where('worked_on LIKE ?', "#{params[:worked_on]}" + "%")
      if @approval_change_attendance_requests.size > 0
        render
      end
    end
  end
  
  private
  
    # 1ヶ月分の勤怠情報を扱う
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :after_started_at, :after_finished_at, :edit_attendance_boss, :note, :spread_day])[:attendances]
    end
    
    # 勤怠情報修正承認・否認時のストロングパラメータ
    def change_attendance_params
      params.require(:user).permit(attendances: [:edit_attendance_request_status])[:attendances]
    end
    
    # 残業申請時のストロングパラメータ
    def overtime_info_params
      params.require(:user).permit(attendances: [:estimated_finished_time, :overtime_spread_day, :overtime_boss, :job_description, :overtime_request_status])[:attendances]
    end
    
    # 残業承認・否認時のストロングパラメータ
    def decision_overtime_params
      params.require(:user).permit(attendances: [:overtime_request_status])[:attendances]
    end
    
end