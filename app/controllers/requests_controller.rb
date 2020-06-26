class RequestsController < ApplicationController
  before_action :set_user
  before_action :logged_in_user
  before_action :superior_or_correct_user
  before_action :set_one_month
  before_action :select_superiors

  def request_one_month
    @request = Request.find(params[:id])
    ActiveRecord::Base.transaction do
      @request.update_attributes!(one_month_request_params)
    end
    @superior = User.find(params[:id])
    flash[:success] = "#{@superior.name}に1ヶ月分の勤怠申請をしました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力があった為、更新をキャンセルしました。"
    redirect_to user_url(date: params[:date])
  end
  
  def receive_one_month_request
    @receive_one_month_requests = Request.where(boss: @user.id, one_month_request_status: "申請中").group_by(&:user_id)
  end
  
  def decision_one_month_request
  
  end
  
  private  
   # 1ヶ月分の勤怠申請時のストロングパラメータ
    def one_month_request_params
      params.require(:user).permit(request: [:id, :boss, :one_month_request_status])
    end
    
    # 1ヶ月分の勤怠承認・否認時のストロングパラメータ
    def decision_one_month_request_params
      params.require(:user).permit(requests_attributes: [:id, :one_month_request_status])
    end
  
end