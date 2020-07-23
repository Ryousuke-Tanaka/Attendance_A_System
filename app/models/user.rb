class User < ApplicationRecord
  has_many :attendances, dependent: :destroy
  has_many :applies, dependent: :destroy
  accepts_nested_attributes_for :applies, allow_destroy: true
  
  # 「remember_token」という仮想の属性を作成
  attr_accessor :remember_token
  before_save { self.email = email.downcase }
  
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  validates :affiliation, length: { in: 2..30 }
  validates :employee_number, presence: true, uniqueness: true, allow_nil: true
  validates :basic_time, presence: true
  validates :work_time, presence: true
  validates :designated_work_start_time, presence: true
  validates :designated_work_end_time, presence: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  
  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = 
      if ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end
    BCrypt::Password.create(string, cost: cost)
  end
  
  # ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  # 永続セッションのためハッシュ化したトークンをデーターベースに記憶
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # トークンがダイジェストと一致すればtrueを返す
  def authenticated?(remember_token)
    # ダイジェストが存在しない場合はfalseを返して終了する
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
  
 # ユーザーのログイン情報を破棄
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  # CSVファイルのimportメソッド
  def self.import(file)
    CSV.foreach(file.path, encoding: 'Shift_JIS:UTF-8', headers: true) do |row|
      # emailが見つかれば、レコードを呼び出し、見つからなければ新規作成
      user = find_by(id: row["email"]) || new
      # CSVファイルからデータを取得し、設定する
      user.attributes = row.to_hash.slice(*updatable_attributes)
      user.save
    end
  end

  
  # 更新を許可するカラムを定義
  def self.updatable_attributes
    ["id", "name", "email", "affiliation", "employee_number", "uid", "password", "password_confirmation",
      "superior", "admin", "basic_time", "designated_work_start_time", "designated_work_end_time"]
  end
  
end
