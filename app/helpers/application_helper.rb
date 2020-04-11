module ApplicationHelper
  
  # ページごとのタイトルを返す
  def full_title(page_name = "")
    base_title = "Attendance_A_App"
    if page_name.empty?
      base_title
    else
      page_name + "|" + base_title
    end
  end
end
