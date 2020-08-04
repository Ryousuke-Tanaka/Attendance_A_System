class Attendance < ApplicationRecord
  belongs_to :user
  
  validates :worked_on, presence: true
  validates :note, length: { maximum: 100 }, presence: true, allow_nil: true
  validates :estimated_finished_time, presence: true, allow_nil: true
  validates :job_description, presence: true, allow_nil: true
  validates :overtime_boss, presence: true, allow_nil: true
  validates :edit_attendance_boss, presence: true, allow_nil: true
  
  # 残業の承認・否認のステータス
  enum overtime_request_status: { なし: 0, 申請中: 1, 承認: 2, 否認: 3 }, _prefix: true
  
  # 勤怠編集の承認・否認のステータス
  enum edit_attendance_request_status: { なし: 0, 申請中: 1, 承認: 2, 否認: 3 }, _prefix: true
  
  # 出勤時間が存在しない場合、退勤時間は無効
  validate :finished_at_is_invalid_without_a_started_at
  
  # 今日以外の日付で退勤時間が存在しない場合、出勤時間は無効
  validate :started_at_is_invalid_without_a_finished_at
  validate :before_started_at_is_invalid_without_a_before_finished_at
  validate :after_started_at_is_invalid_without_a_after_finished_at
  
  # 出勤・退勤時間どちらも存在する場合、出勤時間よりも退勤時間が早い場合は無効
  validate :started_at_than_finished_at_fast_if_invalid
  validate :before_started_at_than_before_finished_at_fast_if_invalid
  validate :after_started_at_than_after_finished_at_fast_if_invalid
  
  
  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if (started_at.blank? && finished_at.present?)  || (before_started_at.blank? && before_finished_at.present?) || (after_started_at.blank? && after_finished_at.present?)
  end
  
  def started_at_is_invalid_without_a_finished_at
    if worked_on < Date.current
      unless (started_at.present? && finished_at.present?) || (started_at.blank? && finished_at.blank?)
        errors.add(:finished_at, "が必要です")
      end
    end
  end
  
  def before_started_at_is_invalid_without_a_before_finished_at
    if worked_on < Date.current
      unless (before_started_at.present? && before_finished_at.present?) || (before_started_at.blank? && before_finished_at.blank?)
        errors.add(:before_finished_at, "が必要です")
      end
    end
  end
  
  def after_started_at_is_invalid_without_a_after_finished_at
    if worked_on < Date.current
      unless (after_started_at.present? && after_finished_at.present?) || (after_started_at.blank? && after_finished_at.blank?)
        errors.add(:after_finished_at, "が必要です")
      end
    end
  end
  
  def started_at_than_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present? && !spread_day
      errors.add(:started_at, "より早い退勤時間は無効です。") if started_at > finished_at
    end
  end
  
  def before_started_at_than_before_finished_at_fast_if_invalid
    if before_started_at.present? && before_finished_at.present? && !spread_day
      errors.add(:before_started_at, "より早い退勤時間は無効です。") if before_started_at > before_finished_at
    end
  end
  
  def after_started_at_than_after_finished_at_fast_if_invalid
    if after_started_at.present? && after_finished_at.present? && !spread_day
      errors.add(:after_started_at, "より早い退勤時間は無効です。") if after_started_at > after_finished_at
    end
  end

end
