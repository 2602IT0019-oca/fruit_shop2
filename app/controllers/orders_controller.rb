class OrdersController < ApplicationController
  def new
    @order = Order.new 
    @product = Product.find(params[:product_id])   # URLから商品を取得
  end

  def new
    @order = Order.new   # 新しい注文オブジェクトを作成
    @cart_items = current_user.cart.cart_items.includes(:product)  # カート内の商品情報を取得
    user_cart_calculation
  end
  
  def index
    @orders = current_user.orders.order(created_at: :desc)  # ユーザーに紐付いた注文履歴を表示
  end

  # 注文内容の確認画面
def confirm
  @order = Order.new(order_params)  # 注文オブジェクトを新規作成
  @order.user_id = current_user.id  # 現在のユーザーIDを紐付け
  # カート内のアイテムを取得
  @cart_item = current_user.cart.cart_items.includes(:product)
  
  @cart_item.each do |item|
    # build を使うとオブジェクトが作成され order_id カラムが自動的にセットされる
    @order.order_details.build(
      product_id: item.product.id,
      quantity: item.quantity,
      price: item.product.price
    )
  end
  # 個々の商品の小計を配列で作る（モジュールのメソッドを使う場合）
  item_totals = @order.order_details.map do |detail|
    calculate_item_total(detail.price, detail.quantity)
  end

  # 合計金額をセット
  @order.total_price = calculate_total_sum(item_totals)

  if !@order.valid?
    # バリデーションNGなら入力画面に戻る
    redirect_to new_order_path, alert: "注文内容に誤りがあります。"
  end
end
  
  # 注文登録
def create
  @order = Order.new(order_params)
  @order.user_id = current_user.id # 現在のユーザーIDを紐付け(不正な値を防ぐため)

  # 親の注文データを保存し、IDを確定させる
  if @order.save
    # カート内の商品を注文詳細として即座にデータベースに保存
    current_user.cart.cart_items.each do |item|
      OrderDetail.create(
        order_id: @order.id,
        product_id: item.product.id,
        quantity: item.quantity,
        price: item.product.price
      )
    end
    # カートのアイテムを空にする
    current_user.cart.cart_items.destroy_all # カート内のアイテムを全て削除
    
    redirect_to complete_order_path(@order)     # 登録が完了したら注文完了ページへ遷移
  else
    redirect_to new_order_path, alert: "注文内容に誤りがあります。" 
  end
end

  # 注文完了
  def complete
    @order = Order.find(params[:id])
  end

  private
  
  def order_params
    params.require(:order).permit(:product_id, :count, :address, :total_price)
  end

  def cal_total_price(price, count)
    return price * count  # 商品価格と個数を掛けて合計金額を返す
  end
end