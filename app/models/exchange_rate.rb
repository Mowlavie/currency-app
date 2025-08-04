class ExchangeRate < ApplicationRecord
    validates :base_currency, presence: true, length: { is: 3 }
    validates :target_currency, presence: true, length: { is: 3 }
    validates :rate, presence: true, numericality: { greater_than: 0 }
    validates :fetched_at, presence: true
  
    validate :currencies_are_different
    validate :currencies_are_uppercase
  
    scope :fresh, -> { where('fetched_at > ?', 1.hour.ago) }
    
    def self.find_or_fetch(base, target)
      rate = fresh.find_by(base_currency: base, target_currency: target)
      return rate if rate
  
      fetch_from_api(base, target)
    end
  
    def expired?
      fetched_at < 1.hour.ago
    end
  
    private
  
    def self.fetch_from_api(base, target)
      response = HTTParty.get("https://api.frankfurter.app/latest?from=#{base}&to=#{target}")
      
      if response.success? && response.parsed_response['rates']
        rate_value = response.parsed_response['rates'][target]
        
        create!(
          base_currency: base,
          target_currency: target,
          rate: rate_value,
          fetched_at: Time.current
        )
      else
        raise StandardError, "Unable to fetch exchange rate"
      end
    end
  
    def currencies_are_different
      if base_currency == target_currency
        errors.add(:target_currency, "must be different from base currency")
      end
    end
  
    def currencies_are_uppercase
      errors.add(:base_currency, "must be uppercase") if base_currency != base_currency&.upcase
      errors.add(:target_currency, "must be uppercase") if target_currency != target_currency&.upcase
    end
  end