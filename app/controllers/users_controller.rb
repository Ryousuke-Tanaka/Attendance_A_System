class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :update_user_info, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:show, :index, :show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:index, :destroy, :update_user_info, :edit_basic_info, :update_basic_info]
  before_action :set_one_month, only: :show
  
  def index
    @users = User.paginate(page: params[:page], per_page: 20 )
    if params[:name].present?
      @users = @users.get_by_name params[:name]
    end
  end
  
  def show
   @worked_sum = @attendances.where.not(started_at: nil).count
   @superiors = User.all.where(superior: true)
  end
  
  def new
    @user = User.new
  end
  
  def create
    if current_user.admin?
      registered_count = import_users
      flash[:success] = "#{registered_count}件登録しました"
      redirect_to users_url
    else
      @user = User.new(user_params)
      if @user.save
        log_in @user # 保存成功後、ログインする
        flash[:success] = "新規作成に成功しました。"
        redirect_to @user
      else
        render :new
      end
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :index
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def update_user_info
    if @user.update_attributes(user_info_params)
      flash[:success] = "#{@user.name}のデータを更新しました。"
      redirect_to users_url
    else
      render :index
    end
  end
  
  def edit_basic_info
  end
  
  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
      redirect_to user_url
    else
      flash.now[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
      render :edit_basic_info
    end
  end
  
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
