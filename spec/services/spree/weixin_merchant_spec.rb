require 'spec_helper'
require 'json'
require 'weixin_rails_middleware'
module Spree
  describe WeixinMerchant do
    before(:all) {
      pro = create(:base_product, price: 0.07, currency: 'CNY')
      variant = create(:base_variant, product: pro, price: 0.07, sku: 'sku1001', currency: 'CNY', cost_currency: 'CNY' )
      variant.currency = 'CNY'
      variant.save
      variant.reload
      #price = create(:price, variant: variant, amount: 7, currency: 'CNY')
      #pro = create(:product, variant: variant)
      #pro = create(:product, price: 7, sku: 'sku1001', currency: 'CNY')
      # puts "*"*100
      # puts "#{pro.inspect}"
      # puts "#{pro.variants[0].inspect}"

      # puts "-"*100
      # puts "#{pro.variants[0].price.inspect}"
      # puts "#{pro.variants[0].currency}"
      # puts "?" * 100
      # puts "#{pro.price.inspect}"
      # puts "#{variant.currency}"
      # puts "#{price.inspect}"
      # puts "*"*100
      create(:wxpay)
    }
    before { 
      Spree::WeixinMerchant.service = ::WeixinMerchant::Service.new(
        double( 
               is_valid?: true, 
               user: double(result: user_info),
               get_order: double(result: order_info)
              )
      )
    }

    #specify { expect { Spree::WeixinMerchant::Service.handle_order_paid_event(order) }.not_to raise_error }
    #specify { expect { Spree::WeixinMerchant.handle_order_paid_event(WeixinRailsMiddleware::Message.factory(notify_msg)) }.not_to raise_error }
    it "processes incoming Weixin payment event" do
      Spree::WeixinMerchant.handle_order_paid_event(WeixinRailsMiddleware::Message.factory(notify_msg))
      created_user = Spree::User.last
      created_order = Spree::Order.last
      expect(created_user.login).to eq user_info['unionid']
      expect(created_user.email).to eq "#{user_info['nickname'].downcase}@mail.weixin.qq.com"
      expect(created_order).to be_complete
      expect(created_user.user_authentications[0][:provider]).to eq 'wechat'
      expect(created_user.user_authentications[0][:uid]).to eq 'o6_bmasdasdsad6_2sgVt7hMZOPfL'
    end

    def notify_msg
      '<xml><ToUserName><![CDATA[gh_c1ad7e71b6d2]]></ToUserName>
<FromUserName><![CDATA[o2Hzljt7pBjEvfD8JOZdXDToSZSc]]></FromUserName>
<CreateTime>1418808423</CreateTime>
<MsgType><![CDATA[event]]></MsgType>
<Event><![CDATA[merchant_order]]></Event>
<OrderId><![CDATA[10296773390408887643]]></OrderId>
<OrderStatus>2</OrderStatus>
<ProductId><![CDATA[p2Hzljh0HJy6dZr1ig3fOiNuXBLw]]></ProductId>
<SkuInfo><![CDATA[sku1001]]></SkuInfo>
</xml>'
    end
    def user_info
      JSON.parse '{
    "subscribe": 1, 
    "openid": "o2Hzljt7pBjEvfD8JOZdXDToSZSc", 
    "nickname": "Band", 
    "sex": 1, 
    "language": "zh_CN", 
    "city": "广州", 
    "province": "广东", 
    "country": "中国", 
    "headimgurl":    "http://wx.qlogo.cn/mmopen/g3MonUZtNHkdmzicIlibx6iaFqAc56vxLSUfpb6n5WKSYVY0ChQKkiaJSgQ1dZuTOgvLLrhJbERQQ4eMsv84eavHiaiceqxibJxCfHe/0", 
   "subscribe_time": 1382694957,
   "unionid": "o6_bmasdasdsad6_2sgVt7hMZOPfL"
}'
    end

    def order_info
      {"order"=>{"order_id"=>"10296773390408906291", "order_status"=>2, "order_total_price"=>7, "order_create_time"=>1418892611, "order_express_price"=>0, "buyer_openid"=>"o2Hzljt7pBjEvfD8JOZdXDToSZSc", "buyer_nick"=>"老爱踢牛", "receiver_name"=>"叶树剑", "receiver_province"=>"北京市", "receiver_city"=>"北京市", "receiver_address"=>"新源里16号琨莎中心3座801", "receiver_mobile"=>"18611111111", "receiver_phone"=>"18611111111", "product_id"=>"p2HzljmbFj19o5nxRcfNpQB_oAns", "product_name"=>"绣倾城", "product_price"=>7, "product_sku"=>"sku1001", "product_count"=>1, "product_img"=>"http://mmbiz.qpic.cn/mmbiz/aIlCjuXa35Rm7SPWvN7cafwINXoibw6g1L4s07HuUibD6juICRMjic8WDqLGnFHg13T6G4EcTp4Xx7TR4VfYC5bqw/0", "delivery_id"=>"", "delivery_company"=>"", "trans_id"=>"1009000319201412180007577509", "receiver_zone"=>""}}
    end
  end
end
