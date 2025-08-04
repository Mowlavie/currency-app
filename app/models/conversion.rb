class Conversion < ApplicationRecord
    belongs_to :exchange_rate
  
    validates :amount, presence: true, numericality: { greater_than: 0 }
    validates :converted_amount, presence: true, numericality: { greater_than: 0 }
    validates :base_currency, presence: true, length: { is: 3 }
    validates :target_currency, presence: true, length: { is: 3 }
  
    validate :currencies_are_different
    validate :currencies_are_uppercase
  
    scope :recent, -> { order(created_at: :desc) }
  
    def self.perform(amount, base, target)
      exchange_rate = ExchangeRate.find_or_fetch(base.upcase, target.upcase)
      converted_amount = amount * exchange_rate.rate
  
      create!(
        amount: amount,
        converted_amount: converted_amount,
        base_currency: base.upcase,
        target_currency: target.upcase,
        exchange_rate: exchange_rate
      )
    end
  
    private
  
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