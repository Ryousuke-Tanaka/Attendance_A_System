class BasesController < ApplicationController
  def index
    @bases = Base.all.order(id: "DESC") 
    @base = Base.find(params[:user_id])
  end
  
  def new
    @base = Base.new
  end
  
  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = "新規拠点登録に成功しましました。"
      redirect_to user_bases_url
    else
      render :index
    end
  end
  
  def edit
  end
  
  def update
    if @base.update_attributes(base_params)
      flash[:success] = "#{@base.base_name}のデータを編集しました。"
      redirect_to user_bases_url
    else
        render :index
    end
  end
  
  def destroy
    @base.destroy
    flash[:success] = "#{@base.base_name}のデータを削除しました。"
    redirect_to user_bases_url
  end
  
  private
    
    def base_params
      params.require(:user).permit(:base_id, :base_name, :attendance_type)
    end
end
