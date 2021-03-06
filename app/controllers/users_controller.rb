class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :update_user_info, :edit_basic_info, :update_basic_info, :export]
  before_action :logged_in_user, only: [:show, :index, :show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :export]
  before_action :correct_user, only: [:edit, :update, :export]
  before_action :admin_user, only: [:index, :destroy, :update_user_info, :edit_basic_info, :update_basic_info, :working_employee]
  before_action :superior_or_correct_user, only: :show
  before_action :set_one_month, only: [:show, :export]
  before_action :not_admin_user, only: :show
  before_action :select_superiors, only: :show
  
  def index
    @users = User.paginate(page: params[:page], per_page: 20 )
    if params[:name].present?
      @users = @users.get_by_name params[:name]
    end
  end
  
  def show
    @worked_sum = @attendances.where.not(started_at: nil).count
    @overtime_requests = Attendance.where(overtime_boss: @user.id, overtime_request_status: "申請中")
    @one_month_requests = Apply.where(one_month_boss: @user.id, one_month_request_status: "申請中")
    @change_attendance_requests = Attendance.where(edit_attendance_boss: @user.id, edit_attendance_request_status: "申請中")
    @one_month_attendance = @one_month_attendance.find_by(one_month: @first_day)
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user # 保存成功後、ログインする
      flash[:success] = "新規作成に成功しました。"
      redirect_to @user
    else
      render :new
    end
  end
  
  def edit
  end
  
  # 各ユーザーからの更新
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      if current_user.admin?
        redirect_to root_url
      else
        redirect_to @user
      end
    else
      render :edit
    end
  end
  
   # 管理者によるユーザー情報更新
  def update_user_info
    if @user.update_attributes(user_info_params)
      flash[:success] = "#{@user.name}のデータを更新しました。"
      redirect_to users_url
    else
      flash[:danger] = "データの更新に失敗しました。<br>" + @user.errors.full_messages.join("<br>")
      redirect_to users_url
    end
  end
  
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
  end
  
  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "基本情報を更新しました。"
      redirect_to users_url
    else
      flash.now[:danger] = "基本情報の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
      render :edit_basic_info
    end
  end
  
  # ユーザー検索
  def search
    if params[:name].present?
      @users = User.where('name LIKE ?', "%#{params[:name]}%").paginate(page: params[:page], per_page: 20 )
      flash.now[:success] = "#{@users.count}件ヒットしました。"
    else
      @users = User.paginate(page: params[:page], per_page: 20 )
      flash.now[:danger] = "該当ユーザーはいませんでした。"
    end
    render :index
  end
  
  # CSVインポート
  def import
    if params[:file].blank?
      flash[:danger] = "インポートするCSVファイルを選択してください。"
      redirect_to users_url
    else
      User.import(params[:file])
      flash[:success] = "CSVファイルをインポートしました。"
      redirect_to users_url
    end
  end
  
  # CSVエクスポート
  def export
    @worked_sum = @attendances.where.not(started_at: nil).count
    respond_to do |format|
      format.csv do
        send_data render_to_string, filename: "#{@user.name}_勤務表_(#{@first_day.strftime('%Y年%-m月')}).csv", type: :csv
      end
    end
  end
  
  # 出勤中社員判定
  def working_employee
    Attendance.where.not(started_at: nil).each do |attendance|
      if (Date.current == attendance.worked_on) && attendance.finished_at.nil?
        @working_users = User.all.includes(:attendances)
      end
    end
  end
  
  private
  
    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :password, :password_confirmation)
    end
    
    def user_info_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid, :password, 
        :password_confirmation, :basic_time, :designated_work_start_time, :designated_work_end_time)
    end
    
   def basic_info_params
      params.require(:user).permit(:department, :basic_time, :work_time)
   end
   
end