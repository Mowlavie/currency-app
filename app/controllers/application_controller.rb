class ApplicationController < ActionController::Base
  # Only apply CSRF protection to non-API routes
  protect_from_forgery with: :exception, unless: -> { request.format.json? }
end