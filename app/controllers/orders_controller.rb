# -*- coding: utf-8 -*-
require "securerandom"

class OrdersController < ApiController

        before_action :authenticate_user!

        def index
                @type = params[:type] || "all"
                @orders = Order.where(customer: current_user).type(@type).order(id: :desc).paginate(:page => params[:page])
        end

        def show
                @order = Order.find(params[:id])
                @url = payment_redirect_url(@order)
        end

        def wechat_pay
                code = params[:code]
                @order_id = params[:state]
                @wechat_params = WechatService.new.pay(Order.find(@order_id), request.remote_ip, code)
        end

        def add
                unless validate
                        flash["info"] = "购物失败"
                        flash["errors"] = @errors
                        redirect_to :carts_confirm
                        return
                end
                begin
                        order = Order.new
                        order.customer = current_user
                        order.seller = get_seller
                        Order.transaction do
                                order.orders_products = get_orders_products
                                order.status = Order.statuses[:placed]
                                order.subtotal = subtotal(order.orders_products)
                                order.order_id = "#{SecureRandom.random_number(10**7)}-#{SecureRandom.random_number(10**7)}"
                                order.address = get_address
                                order.payment_type = params[:paymentType]
                                order.name = order_name order.orders_products
                                order.save!
                                update_product_sales(order.orders_products, :+)
                        end
                        clear_cart
                        redirect_to payment_redirect_url(order)
                rescue => error
                        logger.error error
                        flash["info"] = "购物失败"
                        flash["errors"] = @errors
                        redirect_to :carts_confirm
                end

        end

        def cancel
                order = Order.find(params[:id])
                if order and order.customer.id.eql? current_user.id
                        if order.placed?
                                order.status = Order.statuses[:canceled]
                                begin
                                        Order.transaction do
                                                order.save!
                                                update_product_sales(order.orders_products, :-)
                                        end
                                rescue => error
                                        logger.error error
                                        flash[error] = [@errors]
                                end
                        else
                                flash[error] = ["已支付订单无法取消，如有疑问请联系客服。"]
                        end
                else
                        flash[error] = ["订单不存在"]
                end
                redirect_to action: "show", id: order.id
        end

        private
        def update_product_sales(orders_products, func)
                orders_products.each do |order_product|
                        if order_product.specification.nil?
                                order_product.product.sales = order_product.product.sales.send(func, order_product.count)
                                order_product.product.save!
                        else
                                order_product.specification.sales = order_product.specification.sales.send(func, order_product.count)
                                order_product.specification.save!
                        end
                end
        end
        def order_name(orders_products)
                name = orders_products[0].product.name
                name << "等" if orders_products.size > 1
                name
        end

        def alipay(order)
                return AlipayService.new.pay(order)
        end

        def subtotal(products)
                products.reduce(0) do |sum, p|
                        sum += p.price.to_f * p.count.to_f
                end
        end

        def get_address
                Address.find(params[:addressId])
        end

        def validate
                if get_cart.empty?
                        @errors ||= []
                        @errors << "购物车里没有商品"
                        return false
                end
                true
        end

        def get_seller
                product_id = get_cart[0]["id"]
                Product.find(product_id).owner
        end

        def get_orders_products
                orders_products = []
                get_cart.each do |product|
                        op = OrdersProducts.new
                        op.count = product["count"]
                        p = Product.find(product["id"])
                        op.price = p.price
                        op.product = p
                        unless product["spec_id"].nil? || product["spec_id"].empty?
                                op.specification = Specification.find(product["spec_id"])
                                op.price = op.specification.price
                        end
                        if has_enough_storage? op
                                orders_products << op
                        else
                                @errors ||= []
                                if product["spec_id"].nil?
                                        @errors << "产品[#{p.name}]仅剩#{p.storage-p.sales}件"
                                else
                                        @errors << "产品[#{p.name}]仅剩#{op.specification.storage-op.specification.sales}件"
                                end
                        end
                end
                raise "产品剩余数量不足" unless @errors.nil?
                orders_products
        end

        def has_enough_storage?(order_product)
                storage = (order_product.specification.nil?) ?
                order_product.product.storage - order_product.product.sales :
                        order_product.specification.storage - order_product.specification.sales
                storage >= order_product.count
        end

        def payment_redirect_url(order)
                url = ""
                if order.alipay?
                        url = Config::PAYMENT["alipay"]["mobile_pay"]["url"].clone
                        url << "?" << alipay(order).to_query
                elsif order.wechat?
                        url = WechatService.new.auth_url("http://#{Rails.application.config.domain}/orders/payment/wechat_redirect", order.id)
                elsif order.offline_pay?
                        url = "/orders/#{order.id}"
                end
                url
        end

end