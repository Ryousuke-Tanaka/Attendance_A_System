class BasesController < ApplicationController
  before_action :set_base, only: [:edit, :update, :destroy]
  before_action :logged_in_user
  before_action :admin_user
  
  def index
    @bases = Base.all.order(base_id: "ASC")
    @base = Base.new
  end
  
  def create
    @bases = Base.all.order(base_id: "ASC")
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = "新規拠点登録に成功しましました。"
      redirect_to bases_url
    else
      render :index
    end
  end
  
  def edit
  end
  
  def update
    if @base.update_attributes(base_params)
      flash[:success] = "#{@base.base_name}のデータを編集しました。"
      redirect_to bases_url
    else
        render :index
    end
  end
  
  def destroy
    @base.destroy
    flash[:success] = "#{@base.base_name}のデータを削除しました。"
    redirect_to bases_url
  end
  
  private
    
    def base_params
      params.require(:base).permit(:base_id, :base_name, :attendance_type)
    end
    
    # beforeアクション
    
    def set_base
      @base = Base.find(params[:id])
    end
end
