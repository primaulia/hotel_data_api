class HotelsController < ApplicationController
  def index
    @hotels = Hotel.order(created_at: :desc)

    if params[:hotels].present?
      slugs = params[:hotels].split(',')
      @hotels = @hotels.where(slug: slugs)
    end

    return if params[:destinations].blank?

    destination_ids = params[:destinations].split(',')
    @hotels = @hotels.where(destination_id: destination_ids)
  end
end
