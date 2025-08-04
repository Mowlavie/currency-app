FactoryBot.define do
    factory :exchange_rate do
      base_currency { 'USD' }
      target_currency { 'EUR' }
      rate { 0.85 }
      fetched_at { Time.current }
    end
  
    factory :conversion do
      amount { 100.0 }
      converted_amount { 85.0 }
      base_currency { 'USD' }
      target_currency { 'EUR' }
      exchange_rate
    end
  end