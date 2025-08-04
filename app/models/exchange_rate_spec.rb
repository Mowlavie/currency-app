require 'rails_helper'

RSpec.describe ExchangeRate, type: :model do
  describe 'validations' do
    it 'requires base_currency' do
      rate = ExchangeRate.new(target_currency: 'EUR', rate: 1.2, fetched_at: Time.current)
      expect(rate).not_to be_valid
      expect(rate.errors[:base_currency]).to include("can't be blank")
    end

    it 'requires target_currency' do
      rate = ExchangeRate.new(base_currency: 'USD', rate: 1.2, fetched_at: Time.current)
      expect(rate).not_to be_valid
      expect(rate.errors[:target_currency]).to include("can't be blank")
    end

    it 'requires rate' do
      rate = ExchangeRate.new(base_currency: 'USD', target_currency: 'EUR', fetched_at: Time.current)
      expect(rate).not_to be_valid
      expect(rate.errors[:rate]).to include("can't be blank")
    end

    it 'requires positive rate' do
      rate = ExchangeRate.new(base_currency: 'USD', target_currency: 'EUR', rate: -1.2, fetched_at: Time.current)
      expect(rate).not_to be_valid
      expect(rate.errors[:rate]).to include("must be greater than 0")
    end

    it 'requires fetched_at' do
      rate = ExchangeRate.new(base_currency: 'USD', target_currency: 'EUR', rate: 1.2)
      expect(rate).not_to be_valid
      expect(rate.errors[:fetched_at]).to include("can't be blank")
    end

    it 'requires currencies to be 3 characters' do
      rate = ExchangeRate.new(base_currency: 'US', target_currency: 'EURO', rate: 1.2, fetched_at: Time.current)
      expect(rate).not_to be_valid
      expect(rate.errors[:base_currency]).to include("is the wrong length (should be 3 characters)")
      expect(rate.errors[:target_currency]).to include("is the wrong length (should be 3 characters)")
    end

    it 'requires currencies to be different' do
      rate = ExchangeRate.new(base_currency: 'USD', target_currency: 'USD', rate: 1.2, fetched_at: Time.current)
      expect(rate).not_to be_valid
      expect(rate.errors[:target_currency]).to include("must be different from base currency")
    end

    it 'requires currencies to be uppercase' do
      rate = ExchangeRate.new(base_currency: 'usd', target_currency: 'eur', rate: 1.2, fetched_at: Time.current)
      expect(rate).not_to be_valid
      expect(rate.errors[:base_currency]).to include("must be uppercase")
      expect(rate.errors[:target_currency]).to include("must be uppercase")
    end
  end

  describe 'scopes' do
    let!(:fresh_rate) { create(:exchange_rate, fetched_at: 30.minutes.ago) }
    let!(:stale_rate) { create(:exchange_rate, base_currency: 'GBP', target_currency: 'JPY', fetched_at: 2.hours.ago) }

    it 'returns only fresh rates' do
      expect(ExchangeRate.fresh).to include(fresh_rate)
      expect(ExchangeRate.fresh).not_to include(stale_rate)
    end
  end

  describe '#expired?' do
    it 'returns true for rates older than 1 hour' do
      rate = build(:exchange_rate, fetched_at: 2.hours.ago)
      expect(rate.expired?).to be true
    end

    it 'returns false for rates within 1 hour' do
      rate = build(:exchange_rate, fetched_at: 30.minutes.ago)
      expect(rate.expired?).to be false
    end
  end

  describe '.find_or_fetch' do
    context 'when fresh rate exists' do
      let!(:existing_rate) { create(:exchange_rate, base_currency: 'USD', target_currency: 'EUR', fetched_at: 30.minutes.ago) }

      it 'returns existing rate' do
        result = ExchangeRate.find_or_fetch('USD', 'EUR')
        expect(result).to eq(existing_rate)
      end
    end

    context 'when no fresh rate exists' do
      before do
        allow(HTTParty).to receive(:get).and_return(
          double(success?: true, parsed_response: { 'rates' => { 'EUR' => 0.85 } })
        )
      end

      it 'fetches new rate from API' do
        result = ExchangeRate.find_or_fetch('USD', 'EUR')
        expect(result.base_currency).to eq('USD')
        expect(result.target_currency).to eq('EUR')
        expect(result.rate).to eq(0.85)
      end
    end
  end
end