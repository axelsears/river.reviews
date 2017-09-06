class MunicipalitiesController < ApplicationController

  def index
    @state = State.find_by_abbreviation(params[:state_abbreviation].upcase)
    @municipalities = @state.municipalities.order(:name)
    render json: @municipalities
  end

end
