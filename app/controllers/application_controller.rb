class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  
  $days_of_the_week = %w{日 月 火 水 木 金 土}
  
  # ページ出力前に1ヶ月分のデータの存在を確認・セットします。
  def set_one_month
    @first_day = Date.current.beginning_of_month
    @last_day = Date.current.beginning_of_month
    one_month = [*@first_day..@last_day] # 対象の月の日数を代入
    # ユーザーに紐づく一か月分のレコードを検索し取得
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day)
    
    unless one_month.count == @attendances.count # それぞれの件数（日数が）一致するか判定
      ActiveRecord::Base.transaction do # トランザクション開始
      # 繰り返し処理により、1ヶ月分の勤怠データを生成
      one_month.each { |day| @user.attendances.create!(worked_on: day) }
    end
  end
  
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラー分岐
    flash[:danger] = "ページ情報の取得に失敗しました。再アクセスして下さい。"
    redirect_to root_url
  end
end
