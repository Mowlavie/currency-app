require 'rails_helper'

RSpec.describe Conversion, type: :model do
  let(:exchange_rate) { create(:exchange_rate) }

  describe 'validations' do
    it 'requires amount' do
      conversion = Conversion.new(exchange_rate: exchange_rate, converted_amount: 85.0, 
                                 base_currency: 'USD', target_currency: 'EUR')
      expect(conversion).not_to be_valid
      expect(conversion.errors[:amount]).to include("can't be blank")
    end

    it 'requires positive amount' do
      conversion = Conversion.new(amount: -100, exchange_rate: exchange_rate, converted_amount: 85.0,
                                 base_currency: 'USD', target_currency: 'EUR')
      expect(conversion).not_to be_valid
      expect(conversion.errors[:amount]).to include("must be greater than 0")
    end

    it 'requires converted_amount' do
      conversion = Conversion.new(amount: 100, exchange_rate: exchange_rate,
                                 base_currency: 'USD', target_currency: 'EUR')
      expect(conversion).not_to be_valid
      expect(conversion.errors[:converted_amount]).to include("can't be blank")
    end

    it 'requires positive converted_amount' do
      conversion = Conversion.new(amount: 100, converted_amount: -85.0, exchange_rate: exchange_rate,
                                 base_currency: 'USD', target_currency: 'EUR')
      expect(conversion).not_to be_valid
      expect(conversion.errors[:converted_amount]).to include("must be greater than 0")
    end

    it 'requires base_currency' do
      conversion = Conversion.new(amount: 100, converted_amount: 85.0, exchange_rate: exchange_rate,
                                 target_currency: 'EUR')
      expect(conversion).not_to be_valid
      expect(conversion.errors[:base_currency]).to include("can't be blank")
    end

    it 'requires target_currency' do
      conversion = Conversion.new(amount: 100, converted_amount: 85.0, exchange_rate: exchange_rate,
                                 base_currency: 'USD')
      expect(conversion).not_to be_valid
      expect(conversion.errors[:target_currency]).to include("can't be blank")
    end

    it 'requires currencies to be different' do
      conversion = Conversion.new(amount: 100, converted_amount: 100, exchange_rate: exchange_rate,
                                 base_currency: 'USD', target_currency: 'USD')
      expect(conversion).not_to be_valid
      expect(conversion.errors[:target_currency]).to include("must be different from base currency")
    end

    it 'requires currencies to be uppercase' do
      conversion = Conversion.new(amount: 100, converted_amount: 85.0, exchange_rate: exchange_rate,
                                 base_currency: 'usd', target_currency: 'eur')
      expect(conversion).not_to be_valid
      expect(conversion.errors[:base_currency]).to include("must be uppercase")
      expect(conversion.errors[:target_currency]).to include("must be uppercase")
    end
  end

  describe '.perform' do
    before do
      allow(ExchangeRate).to receive(:find_or_fetch).and_return(exchange_rate)
    end

    it 'creates a new conversion with calculated amount' do
      conversion = Conversion.perform(100, 'USD', 'EUR')
      
      expect(conversion.amount).to eq(100)
      expect(conversion.base_currency).to eq('USD')
      expect(conversion.target_currency).to eq('EUR')
      expect(conversion.converted_amount).to eq(100 * exchange_rate.rate)
      expect(conversion.exchange_rate).to eq(exchange_rate)
    end

    it 'converts currencies to uppercase' do
      conversion = Conversion.perform(100, 'usd', 'eur')
      
      expect(conversion.base_currency).to eq('USD')
      expect(conversion.target_currency).to eq('EUR')
    end
  end

  describe 'scopes' do
    let!(:old_conversion) { create(:conversion, created_at: 1.day.ago) }
    let!(:new_conversion) { create(:conversion, created_at: 1.hour.ago) }

    it 'orders by created_at desc in recent scope' do
      expect(Conversion.recent.first).to eq(new_conversion)
      expect(Conversion.recent.last).to eq(old_conversion)
    end
  end
end