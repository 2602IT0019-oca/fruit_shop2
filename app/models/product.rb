class Product < ApplicationRecord
  # 関連付け（アソシエーション）の検索許可を設定
  def self.ransackable_associations(auth_object = nil)
    ["cart_items", "carts", "order_details", "orders", "photo_attachment", "photo_blob"]
  end

  # カラム（属性）の検索許可が未設定の場合はこちらも記載しておきます
  def self.ransackable_attributes(auth_object = nil)
    ["id", "name", "price", "created_at", "updated_at"]
  end
  # バリデーション
  validates :name, presence: true, uniqueness: true  # 商品名は必須で一意
  validates :price, presence: true                   # 価格は必須

  # 関連付け（カート）
  has_many :cart_items, dependent: :destroy  # 商品は複数のカートアイテムと関連（1対多）
  has_many :carts, through: :cart_items      # 中間テーブルを通じて複数のカートと関連（多対多）

  # 関連付け（注文）
  has_many :order_details                    # 商品は複数の注文と関連（1対多）
  has_many :orders, through: :order_details  # 中間テーブルを通じて複数の注文と関連（多対多）

  # Active Storage（商品画像）
  has_one_attached :photo

  # 商品画像のサムネイルを生成
  def thumbnail
    photo.variant(resize_to_limit: [150, 150]).processed  # 画像を 150x150 ピクセル以内にリサイズ
  end

  # Enum（販売状況）
  # エラーの原因（旧構文）
  # app/models/product.rb

  # 修正後（新構文）
  enum :status, { on_sale: 0, sold_out: 1 }
 # 検索（Ransack）
  def self.ransackable_attributes(auth_object = nil)
    %w[name price]
  end
end