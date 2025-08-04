require 'rails_helper'

RSpec.describe Api::ConversionsController, type: :controller do
  describe 'POST #convert' do
    let(:exchange_rate) { create(:exchange_rate, rate: 0.85) }
    
    before do
      allow(Conversion).to receive(:perform).and_return(
        create(:conversion, amount: 100, converted_amount: 85, exchange_rate: exchange_rate)
      )
    end

    it 'returns conversion result as JSON' do
      post :convert, params: { amount: 100, base_currency: 'USD', target_currency: 'EUR' }
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      
      expect(json_response['amount']).to eq(100.0)
      expect(json_response['converted_amount']).to eq(85.0)
      expect(json_response['base_currency']).to eq('USD')
      expect(json_response['target_currency']).to eq('EUR')
      expect(json_response['exchange_rate']).to eq(0.85)
    end

    it 'handles errors gracefully' do
      allow(Conversion).to receive(:perform).and_raise(StandardError.new('API Error'))
      
      post :convert, params: { amount: 100, base_currency: 'USD', target_currency: 'EUR' }
      
      expect(response).to have_http_status(:unprocessable_entity)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('API Error')
    end
  end

  describe 'GET #conversions' do
    let!(:conversions) { create_list(:conversion, 3) }

    it 'returns recent conversions as JSON' do
      get :conversions
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      
      expect(json_response.length).to eq(3)
      expect(json_response.first).to include('amount', 'converted_amount', 'base_currency', 'target_currency')
    end
  end
end