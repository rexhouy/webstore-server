class ImmediateOrderService < OrderService

        def create(cart, payment_type, user_coupon, use_account_balance, dinning_table_id, shop_id, current_user)
                @order = ImmediateOrder.new
                @order.dinning_table_id = dinning_table_id
                @order.seller_id = shop_id
                super(cart, payment_type, "", user_coupon, use_account_balance, current_user)
        end

end