class AppliesController < ApplicationController
  before_action :set_user
  before_action :logged_in_user
  before_action :superior_or_correct_user
  before_action :set_one_month
  before_action :select_superiors

  def request_one_month
    ActiveRecord::Base.transaction do
      one_month_request_params.each do |id ,item|
        if params[:user][:applies][id][:one_month_boss].blank?
          flash[:danger] = "上長を選択してください。"
          redirect_to user_url(date: params[:date]) and return
        else
          one_month_request = Apply.find(id)
          one_month_request.update_attributes!(item)
          @superior = User.find(params[:user][:applies][id][:one_month_boss])
        end
      end
    end
    flash[:success] = "#{@superior.name}に1ヶ月分の勤怠申請をしました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力があった為、更新をキャンセルしました。"
    redirect_to user_url(date: params[:date])
  end
  
  def receive_one_month_request
    @receive_one_month_requests = Apply.where(one_month_boss: @user.id, one_month_request_status: "申請中").group_by(&:user_id)
  end
  
  def decision_one_month_request
    ActiveRecord::Base.transaction do
      decision_one_month_request_params.each do |id ,item|
        decision_one_month_request = Apply.find(id)
        if params[:user][:applies][id][:change] == "true"
          decision_one_month_request.update_attributes!(item)
        else
          flash[:danger] = "変更にチェックを入れてください。"
        end
      end
    end
    flash[:success] = "1ヶ月勤怠申請の決裁を更新しました。"
    redirect_to user_url(current_user, date: params[:date])
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力があった為、更新をキャンセルしました。"
    redirect_to user_url(date: params[:date])
  end
  
  private  
   # 1ヶ月分の勤怠申請時のストロングパラメータ
    def one_month_request_params
      params.require(:user).permit(applies: [:one_month_boss, :one_month_request_status, :id, :_destroy])[:applies]
    end
    
    # 1ヶ月分の勤怠承認・否認時のストロングパラメータ
    def decision_one_month_request_params
      params.require(:user).permit(applies: [:one_month_request_status, :id, :_destroy])[:applies]
    end
  
end

