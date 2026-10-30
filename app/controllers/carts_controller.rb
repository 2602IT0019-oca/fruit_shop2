class CartsController < ApplicationController
  before_action :authenticate_user! # 未ログインの場合はログイン画面へリダイレクト

  def index
    # カート一覧画面（単一カートの場合は show へリダイレクト）
    redirect_to cart_path(current_user.cart || current_user.create_cart)
  end

  def show
    # idパラメータからカートを取得、なければログインユーザーのカートを取得
    @cart = current_user.cart || current_user.create_cart
    
    # カート内の商品一覧を取得
    @cart_items = @cart.cart_items.includes(:product)

    # 各商品の小計と合計金額の計算
    @item_totals = @cart_items.map { |item| item.product.price * item.quantity }
    @cart_total = @item_totals.sum
  end

  def add_product
    @cart = current_user.cart || current_user.create_cart
    product_id = params[:product_id] || params[:id]
    quantity = params[:quantity].to_i.positive? ? params[:quantity].to_i : 1

    @cart_item = @cart.cart_items.find_by(product_id: product_id)

    if @cart_item
      @cart_item.quantity += quantity
    else
      @cart_item = @cart.cart_items.build(product_id: product_id, quantity: quantity)
    end

    if @cart_item.save
      # ルーティングが resources :carts のため @cart を渡してリダイレクト
      redirect_to cart_path(@cart), notice: '商品をカートに追加しました。'
    else
      redirect_back fallback_location: products_path, alert: 'カートへの追加に失敗しました。'
    end
  end

  def remove_item
    @cart = current_user.cart
    @cart_item = @cart.cart_items.find_by(product_id: params[:id]) || @cart.cart_items.find_by(id: params[:id])

    if @cart_item
      @cart_item.destroy
      redirect_to cart_path(@cart), notice: '商品をカートから削除しました。'
    else
      redirect_to cart_path(@cart), alert: '対象の商品が見つかりませんでした。'
    end
  end

  def update_quantity
    @cart = current_user.cart
    @cart_item = @cart.cart_items.find_by(product_id: params[:id]) || @cart.cart_items.find_by(id: params[:id])

    if @cart_item
      quantity = params[:count] || params[:quantity]
      if quantity.to_i > 0
        @cart_item.update(quantity: quantity)
        redirect_to cart_path(@cart), notice: '数量を変更しました。'
      else
        @cart_item.destroy
        redirect_to cart_path(@cart), notice: '商品をカートから削除しました。'
      end
    else
      redirect_to cart_path(@cart), alert: '対象の商品が見つかりませんでした。'
    end
  end
end