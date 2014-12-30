FactoryGirl.define do
  factory :wxpay, class: Spree::BillingIntegration::Wxpay do
    name "微信支付"
    environment 'test'
  end
end
