class BasesController < ApplicationController
  before_action :set_base, only: [:edit, :update, :destroy]
  before_action :admin_user
  
  def index
    @bases = Base.all.order(id: "DESC")
    @base = Base.new
  end
  
  def new
    @base = Base.new
  end
  
  def create
    @bases = Base.all.order(id: "DESC")
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = "新規拠点登録に成功しましました。"
      redirect_to bases_url
    else
      render :index
    end
  end
  
  def edit
    @base = Base.find(params[:id])
  end
  
  def update
    @base = Base.find(params[:id])
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
      @base = Base.find_by(params[:id])
    end
end
