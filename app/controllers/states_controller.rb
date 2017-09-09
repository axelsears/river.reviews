class StatesController < ApplicationController

  def index
    @states = State.all
    render json: @states
  end

  # def show
  #   @state = State.find_by_abbreviation(params[:abbreviation].upcase)
  #   render json: @state
  # end

  # def new
  #   @states = State.new
  # end
  #
  # def create
  #   @state = State.new(state_params)
  #   if @state.save
  #     redirect_to root_path
  #   else
  #     render json: :new
  #   end
  # end

  private

  def place_params
    params.require(:state).permit(:abbreviation, :name, municipalities_attributes: [:name, :zone, :latitude, :longitude], waterways_attributes: [:name, :site_id, :latitude, :longitude])
  end
end
