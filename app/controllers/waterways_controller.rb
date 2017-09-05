class WaterwaysController < ApplicationController

  def index
    # @waterways = Waterway.new(params[:state])
    # render json: @waterways.list
    @waterways = Waterway.all(params[:state])
    render json: @waterways
  end

end
