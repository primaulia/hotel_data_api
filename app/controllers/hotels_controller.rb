class HotelsController < ApplicationController
  def index
    @hotels = Hotel.order(created_at: :desc)
  end
end
