class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month, :request_overtime, :update_overtime]
  before_action :logged_in_user, only: [:update, :edit_one_month, :request_overtime, :update_overtime]
  before_action :correct_user, only: [:request_overtime, :update_overtime, :update_overtime]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month]
  before_action :set_one_month, only: [:edit_one_month, :request_overtime]
  
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
        attendance = Attendance.find(id)
        attendance.update_attributes!(item)
      end
    end
  flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
  redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力があった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  def request_overtime
    @attendance = Attendance.find_by(worked_on: params[:date])
    @attendances = @user.attendances.where(worked_on: @attendance.worked_on)
  end
  
  def update_overtime
    @attendance = Attendance.find(params[:id])
    if @attendance.update_attributes(overtime_info_params)
      flash[:success] = "残業を申請しました。"
    end
  end
  
  
  private
  
    # 1ヶ月分の勤怠情報を扱う
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note, :spread_day])[:attendances]
    end
    
    def overtime_info_params
      params.permit(attendances: [:estimated_finished_time, :spread_day, :job_description, :boss])[:attendances]
    end
end