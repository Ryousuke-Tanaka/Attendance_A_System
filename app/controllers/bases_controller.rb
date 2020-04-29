class BasesController < ApplicationController
  def index
    # @bases = Base.find.all
  end
  
  def new
    @base = Base.new
  end
  
  def create
    @base = Base.new(base_params)
  end
  
  def edit
  end
  
  def updated
  end
  
  def destroy
    @base.destroy
    flash[:success] = "#{@base.base_name}のデータを削除しました。"
    redirect_to bases_url
  end
  
  private
    
    def base_params
      params.require(:user).permit(:base_id, :base_name, :attendance_type)
    end
end
