class Api::ConversionsController < ApplicationController
    protect_from_forgery with: :null_session
  
    def convert
      conversion = Conversion.perform(
        params[:amount].to_f,
        params[:base_currency],
        params[:target_currency]
      )
  
      render json: {
        amount: conversion.amount,
        converted_amount: conversion.converted_amount,
        base_currency: conversion.base_currency,
        target_currency: conversion.target_currency,
        exchange_rate: conversion.exchange_rate.rate,
        rate_fetched_at: conversion.exchange_rate.fetched_at,
        converted_at: conversion.created_at
      }
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  
    def conversions
      conversions = Conversion.includes(:exchange_rate).recent.limit(20)
      
      render json: conversions.map do |conversion|
        {
          id: conversion.id,
          amount: conversion.amount,
          converted_amount: conversion.converted_amount,
          base_currency: conversion.base_currency,
          target_currency: conversion.target_currency,
          exchange_rate: conversion.exchange_rate.rate,
          rate_fetched_at: conversion.exchange_rate.fetched_at,
          converted_at: conversion.created_at
        }
      end
    end
  end