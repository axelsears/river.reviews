class WaterwaysController < ApplicationController

  # def index
  #   # @waterways = Waterway.new(params[:state])
  #   # render json: @waterways.list
  #   # @waterways = Waterway.all(params[:state])
  #   render json: @waterways
  # end

  def index
    state = State.find_by_abbreviation(params[:state_abbreviation].upcase)
    municipality = state.municipalities.find_by_zone(params[:zone])
    render json: municipality.waterways
  end

  # def show_all
  #   state = State.find_by_abbreviation(params[:state_abbreviation].upcase)
  #   puts state
  #   render json: state.waterways
  # end

end
