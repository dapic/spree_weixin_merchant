module Spree::WeixinMerchant
  class Order
    attr_reader :order_id,
      :order_status,
      :order_total_price,
      :order_create_time,
      :order_express_price,
      :buyer_openid,
      :buyer_nick,
      :receiver_name,
      :receiver_province,
      :receiver_city,
      :receiver_address,
      :receiver_mobile,
      :receiver_phone,
      :product_id,
      :product_name,
      :product_price,
      :product_sku,
      :product_img,
      :delivery_id,
      :delivery_company,
      :trans_id
    attr_writer :info

    # order_info should be a WeixinAuthorize::ResultHandler
    #
    def self.from(order_info)
      Order.new() {|o|
        o.info = order_info.result
      }
    end

    def initialize()
      yield
    end
  end
end
