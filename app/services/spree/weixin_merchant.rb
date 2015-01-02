module Spree::WeixinMerchant
  
  cattr_accessor :service
  #class Service
    class << self
    def handle_order_paid_event(weixin_message)
      Rails.logger.debug("handling #{weixin_message.inspect}")
      orderid, user_openid = weixin_message.OrderId, weixin_message.FromUserName
      #user_info = ::WeixinMerchant::Service.get_user(user_openid)
      user_info = service.get_user(user_openid)
      user_uid = user_info.unionid
      spree_user_auth = Spree::UserAuthentication.find_by(provider: 'wechat', uid: user_uid)
      #|| Spree::User.find_by(login:email: "#{user_info.nickname}@mail.weixin.qq.com")
      puts "spree_user_auth is #{spree_user_auth.inspect}"
      spree_user = spree_user_auth ? spree_user_auth.user : create_spree_user(user_info)
      
      puts "user is #{spree_user.inspect}"
      binding.pry
      #order_info = ::WeixinMerchant::Service.get_order(orderid)
      order_info = service.get_order(orderid)
      
      #if user has existing account, create order for that account
      #else create an account
      #In the default spree_core implementation, differenct pieces of info pertaining to the order are created/generated in different checkout steps
      # so we have to mimic that here
      # 1 make sure the user account is created
      # 2 create the order
      # 3 populate the order (fill in the line_items)
      # 4 add address info
      #order = create_spree_order(order_info)
      order_params = build_order_params(order_info).tap{|p| Rails.logger.debug("order_params created to be #{p.inspect}")}
      puts "order_params for importing is #{order_params}"
      order = Spree::Core::Importer::Order.import(spree_user, order_params).tap{|o| Rails.logger.debug "order imported is #{order.inspect}"}
      # 5 update delivery options. because, in theory, the delivery charge is calculated based on the address, which in turn determines the shipments
      # this selects the default shipping method

      while order.next; end
      # 6 add payment info
      puts "order is now: \n #{order.inspect}"
      create_payment(order, order_info)
      #order.next
      puts "order is now: \n #{order.inspect}"
      order.update_attributes( state: 'complete', completed_at: order_info.order_create_time)
      order.updater.update
      order.save!
      puts "order is finally #{order.inspect}"
      puts "payments is finally #{order.payments[0].inspect}"
    end

    def build_order_params(woi)
      params = {}
      params['currency'] = 'CNY'
      params[:ship_address_attributes] = {
        lastname: woi.receiver_name,
        firstname: woi.buyer_nick,
        address1: woi.receiver_address,
      city: woi.receiver_city,
      phone: woi.receiver_phone,
      state_id: Spree::State.find_by(name: woi.receiver_province).id,
      country_id: Spree::Country.find_by(iso: 'CN').id,
      zipcode: 123456
      }
      params[:bill_address_attributes] = params[:ship_address_attributes] 
      params[:line_items_attributes] = { 
        line_item: { 
          variant_id: (get_spree_variant(woi.product_sku.present? ? woi.product_sku : woi.product_id)).id,
          quantity: woi.product_count,
        }
      }
      params
    end

    def create_spree_user(user_info)
      user = Spree::User.find_or_create_by(email: "#{user_info.nickname}@mail.weixin.qq.com")
      user.login = user_info.unionid
      #user = Spree::User.new(login: user_info.unionid, email: "#{user_info.nickname}@mail.weixin.qq.com")
      user.apply_omniauth({'provider' => 'wechat', 'uid' => user_info.unionid})
      user.save!
      user.reload
    end

    def create_payment(order,weixin)
      payment = order.payments.build(order: order, foreign_transaction_id: weixin.trans_id)
      payment.amount = weixin.order_total_price.to_f
      payment.state = 'completed' # we could not get the message unless it's paid
      payment.payment_method = Spree::PaymentMethod.find_by_name!('微信支付')
      payment.save!
      #payment.complete!
    end

    def create_spree_order(user, weixin_order)
      order = user.orders.build(
        currency: 'CNY',
        #total: order.order_total_price,
      )
      create_line_item(order,weixin_order)
      create_payment(order,weixin_order)
      #@current_order = Spree::Order.new( currency: 'CNY')
      @current_order.user ||= try_spree_current_user
      # See issue #3346 for reasons why this line is here
      @current_order.created_by ||= try_spree_current_user
      @current_order.save!
    end

    def order_params
      {currency: 'CNY', user_id: try_spree_current_user.try(:id) }
    end

    # current weixin shop only allows buying one product per order (could be multiple items thou)
    def create_line_item(order,weixin)
      the_spree_variant = get_spree_varient(weixin.product_id)
      line_item = order.contents.add(this_spree_variant, weixin.product_count)
      line_item.update_attributes(price: weixin.product_price)
    end
    def create_shipping_address(weixin)

    end
    def get_spree_variant(weixin_sku)
      Spree::Variant.find_by(sku: weixin_sku) 
      .tap {|v| puts "variant found is #{v.name}"}
    end
  end
#  end
  private
  def setup_weixin_service_client

  end

end
