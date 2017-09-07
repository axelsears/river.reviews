class MunicipalitiesController < ApplicationController

  def index
    state = State.find_by_abbreviation(params[:state_abbreviation].upcase)
    municipalities = state.municipalities.order(:name)
    municipalities_render = municipalities.map{ |m|
      { name: m.name, zone: m.zone, parent: "http://#{request.env['HTTP_HOST']}#{request.env['PATH_INFO']}", child: "http://#{request.env['HTTP_HOST']}#{request.env['PATH_INFO']}/#{m.zone}" }
    }
    render json: municipalities_render
  end

  def show
    state = State.find_by_abbreviation(params[:state_abbreviation].upcase)
    municipality = state.municipalities.find_by_zone(params[:zone])
    render json: municipality
  end

end
