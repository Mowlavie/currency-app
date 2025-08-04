# Currency Converter

A full-stack Rails application with Turbo frontend for real-time currency conversion using live exchange rates.

## Features

- **Real-time Currency Conversion**: Convert between major world currencies
- **Smart Rate Caching**: Exchange rates cached for 1 hour to minimize API calls
- **Conversion History**: Track and display recent conversion activities
- **Responsive UI**: Modern, clean interface built with Turbo for seamless updates
- **API Endpoints**: RESTful API for programmatic access
- **Comprehensive Testing**: Full RSpec test suite with model and controller specs

## Tech Stack

- **Backend**: Ruby on Rails 7.0 (API + Web)
- **Frontend**: Turbo Rails (Hotwire) for SPA-like experience
- **Database**: SQLite (development), PostgreSQL ready
- **External API**: Frankfurter API for live exchange rates
- **Testing**: RSpec with FactoryBot

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd currency-converter
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Setup database**
   ```bash
   rails db:create
   rails db:migrate
   ```

4. **Run the application**
   ```bash
   rails server
   ```

5. **Visit the app**
   Open http://localhost:3000 in your browser

## API Usage

### Convert Currency
```bash
POST /api/convert
Content-Type: application/json

{
  "amount": 100,
  "base_currency": "USD",
  "target_currency": "EUR"
}
```

### Get Conversion History
```bash
GET /api/conversions
```

## Testing

Run the complete test suite:
```bash
bundle exec rspec
```

Run specific test files:
```bash
bundle exec rspec spec/models/
bundle exec rspec spec/controllers/
```

## Project Structure

```
app/
├── controllers/
│   ├── conversions_controller.rb      # Main web interface
│   └── api/
│       └── conversions_controller.rb  # API endpoints
├── models/
│   ├── exchange_rate.rb               # Rate caching logic
│   └── conversion.rb                  # Conversion records
└── views/
    └── conversions/                   # Turbo-powered views

spec/
├── models/                            # Model tests
├── controllers/                       # Controller tests
└── factories.rb                       # Test data factories
```

## Database Schema

### ExchangeRates
- `base_currency`: 3-character currency code (e.g., 'USD')
- `target_currency`: 3-character currency code (e.g., 'EUR') 
- `rate`: Exchange rate value
- `fetched_at`: Timestamp for cache invalidation

### Conversions
- `amount`: Original amount to convert
- `converted_amount`: Result after conversion
- `base_currency`: Source currency
- `target_currency`: Destination currency
- `exchange_rate_id`: Reference to cached rate used

## Key Features Explained

### Rate Caching Strategy
Exchange rates are fetched from Frankfurter API and cached for exactly 1 hour. The system automatically:
- Checks for existing fresh rates before making API calls
- Fetches new rates when cache expires
- Handles API errors gracefully

### Turbo Integration
The frontend uses Turbo Streams for real-time updates without full page reloads:
- Form submissions update multiple page sections simultaneously
- Conversion results appear instantly
- History list updates automatically
- Error handling with inline messages

### Data Validation
Comprehensive validation ensures data integrity:
- Currency codes must be exactly 3 uppercase characters
- Amounts must be positive numbers
- Base and target currencies must differ
- Exchange rates must be positive values

## Development Notes

The application follows Rails conventions with some specific architectural decisions:

- **Single Responsibility**: Each model handles its specific domain logic
- **API Compatibility**: Dual interface (web + API) for flexibility
- **Performance**: Strategic caching reduces external API dependency
- **User Experience**: Turbo provides smooth, modern interactions

## Production Considerations

Before deploying to production:

1. **Database**: Switch to PostgreSQL in production
2. **Environment Variables**: Set up proper API keys and secrets
3. **Caching**: Consider Redis for distributed rate caching
4. **Monitoring**: Add logging for API failures and performance metrics
5. **Rate Limiting**: Implement API rate limiting for public endpoints

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for new functionality
4. Ensure all tests pass (`bundle exec rspec`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request