class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month, :request_overtime, :update_overtime, :receive_overtime]
  before_action :logged_in_user, only: [:update, :edit_one_month, :request_overtime, :update_overtime]
  before_action :correct_user, only: [:request_overtime, :receive_overtime]
  before_action :superior_or_correct_user, only: :update_overtime
  before_action :admin_or_correct_user, only: [:update, :edit_one_month]
  before_action :set_one_month, only: [:edit_one_month, :request_overtime]
  before_action :select_superiors, only: [:edit_one_month, :update_one_month, :request_overtime, :update_overtime]
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"

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
  
  def edit_one_month
  end
  
  def update_one_month
    ActiveRecord::Base.transaction do
      attendances_params.each do |id, item|
        if (item)[:note].present?
          attendance = Attendance.find(id)
          attendance.edit_attendance_request_status = "申請中"        
          attendance.update_attributes!(item)
        end
      end
    end
    flash[:success] = "1ヶ月分の勤怠情報を更新・申請しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid
     flash[:danger] = "無効な入力があった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  # 勤怠修正を申請
  def request_change_attendance
    @change_attendance_requests = Attendance.where(boss: @user.id, edit_attendance_request_status: "申請中").group_by(&:user_id)
  end
  
  # 残業申請
  def request_overtime
    @attendance = Attendance.find_by(worked_on: params[:date])
    @attendances = @user.attendances.where(worked_on: @attendance.worked_on)
  end
  
  # 残業承認・否認
  def receive_overtime
    @overtime_requests = Attendance.where(boss: @user.id, overtime_request_status: "申請中").group_by(&:user_id)
  end
  
  def update_overtime
    @user = User.find(params[:id])
    ActiveRecord::Base.transaction do
      overtime_info_params.each do |id, item|
        @overtime = Attendance.find(id)
        @overtime.update_attributes!(item)
      end
    end
    @superior = User.find(@overtime.boss)
    flash[:success] = "#{@superior.name}に残業申請をしました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力があった為、更新をキャンセルしました。"
    redirect_to user_url(date: params[:date])
  end
  
  def decision_overtime
    ActiveRecord::Base.transaction do
      decision_overtime_params.each do |id, item|
        decision_overtime = Attendance.find(id)
        if params[:user][:attendances][id][:change] == "true"
          decision_overtime.update_attributes!(item)
        else
          flash[:danger] = "変更にチェックを入れてください。"
        end
      end
    end
    flash[:success] = "残業申請の決裁を更新しました。"
    redirect_to user_url(current_user, date: params[:date])
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力があった為、更新をキャンセルしました。"
    redirect_to user_url(current_user, date: params[:date])
  end
  
  # 1ヶ月分の勤怠情報の承認・否認
  def request_one_month
    @attendance = Attendance.find_by(worked_on: params[:date])
    ActiveRecord::Base.transaction do
      decision_one_month_params.each do |id, item|
        decision_one_month = Attendance.find(id)
        decision_one_month.update_attributes!(item)
      end
    end
    flash[:success] = "1ヶ月分の勤怠承認を申請しました。"
    redirect_to user_url(current_user, date: params[:date])
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力があった為、更新をキャンセルしました。"
    redirect_to user_url(current_user, date: params[:date])
  end
  
  def receive_one_month_request
    @receive_one_month_requests = Attendance.where(boss: @user.id, one_month_request_status: "申請中").group_by(&:user_id)
  end
  
  # 勤怠ログ
  def edit_log
  end
  
  
  private
  
    # 1ヶ月分の勤怠情報を扱う
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note, :spread_day, :boss])[:attendances]
    end
    
    # 残業申請時のストロングパラメータ
    def overtime_info_params
      params.require(:user).permit(attendances: [:estimated_finished_time, :spread_day, :job_description, :boss, :overtime_request_status])[:attendances]
    end
    
    # 残業承認時のストロングパラメータ
    def decision_overtime_params
      params.require(:user).permit(attendances: [:overtime_request_status])[:attendances]
    end
    
    # 1ヶ月分の勤怠承認時のストロングパラメータ
    def decision_one_month_params
      params.require(:user).permit(attendances: [:boss, :one_month_request_status])[:attendances]
    end
end