class ConversionsController < ApplicationController
    def index
      @conversion = Conversion.new
      @conversions = Conversion.includes(:exchange_rate).recent.limit(10)
    end
  
    def create
      @conversion = Conversion.perform(
        conversion_params[:amount].to_f,
        conversion_params[:base_currency],
        conversion_params[:target_currency]
      )
  
      respond_to do |format|
        format.turbo_stream do
          @conversions = Conversion.includes(:exchange_rate).recent.limit(10)
          render turbo_stream: [
            turbo_stream.update("conversion_result", partial: "conversion_result", locals: { conversion: @conversion }),
            turbo_stream.update("conversions_list", partial: "conversions_list", locals: { conversions: @conversions }),
            turbo_stream.update("conversion_form", partial: "conversion_form", locals: { conversion: Conversion.new })
          ]
        end
  
        format.html { redirect_to conversions_path }
      end
    rescue => e
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("conversion_result", partial: "error", locals: { error: e.message })
        end
        format.html do
          flash[:error] = e.message
          redirect_to conversions_path
        end
      end
    end
  
    private
  
    def conversion_params
      params.require(:conversion).permit(:amount, :base_currency, :target_currency)
    end
  end
  