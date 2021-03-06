# -*- coding: utf-8 -*-
module Admin::OrdersHelper

        def order_status(order)
                return "等待付款" if order.placed? and order.online_pay?
                return "等待发货" if (order.placed? and order.offline_pay?) or order.paid?
                return "等待收货" if order.shipping?
                return "已完成" if order.finished?
                return "已取消" if order.canceled?
        end

        def order_payment(order)
                return "线上支付" if order.online_pay?
                "货到付款"
        end

end
