class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  
  $days_of_the_week = %w{日 月 火 水 木 金 土}
  
  # beforeフィルター
  
  # paramsハッシュからユーザーを取得
  def set_user
    @user = User.find(params[:id])
  end
  
  # ログイン済みのユーザーか確認
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "ログインしてください。"
      redirect_to login_url
    end
  end
    
  # アクセスしたユーザーが現在ログインしているユーザーか確認
  def correct_user
    unless current_user?(@user)
      flash[:danger] = "他のユーザー情報は閲覧できません。"
      redirect_to(root_url)
    end
  end
  
  # 管理権限者、または現在ログインしているユーザーを許可
  def admin_or_correct_user
    @user = User.find(params[:user_id]) if @user.blank?
    unless current_user?(@user) || current_user.admin?
      flash[:danger] = "閲覧・編集権限がありません。"
      redirect_to(root_url)
    end
  end

  # 管理者か判定
  def admin_user
    unless current_user.admin?
      flash[:danger] = "管理者のみ閲覧可能です。"
      redirect_to root_url
    end
  end
  
  # 管理者でないことを判定
  def not_admin_user
    if current_user.admin?
      flash[:danger] = "管理者は閲覧できません。"
      redirect_to root_url
    end
  end
  
  # 勤怠情報のユーザー本人または上長を許可
  def superior_or_correct_user
    @user = User.find(Attendance.find(params[:id]).user_id) if @user.blank?
    unless current_user?(@user) || current_user.superior?
      flash[:danger] = "閲覧・編集権限がありません。"
      redirect_to(root_url)
    end
  end
  
  # Userテーブルから上長を取り出す（自分の場合を除く）
  def select_superiors
    @superiors = User.all.where(superior: true).where.not(id: @user)
  end
  
  # ページ出力前に1ヶ月分のデータの存在を確認・セット
  def set_one_month
    @first_day = params[:date].nil? ?
    Date.current.beginning_of_month : params[:date].to_date
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day]
  
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    @one_month_attendance = @user.applies.where(one_month: @first_day)
  
    unless one_month.count == @attendances.count
      ActiveRecord::Base.transaction do
        one_month.each { |day| @user.attendances.create!(worked_on: day, one_month: @first_day) }
        @user.applies.create!(one_month: @first_day)
      end
      @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
      @one_month_attendance = @user.applies.where(one_month: @first_day)
    end
  
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。"
    redirect_to root_url
  end
  
end
