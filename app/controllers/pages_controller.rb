class PagesController < ApplicationController
  def index
    @feed_back = FeedBack.new
  end

  def show
    @feed_back = FeedBack.new
    render template: "pages/#{params[:page]}"
  end
end