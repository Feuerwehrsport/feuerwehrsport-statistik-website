class NewsController < ResourceController
  def index
    @news = News.all.index_order.decorate
  end

  def show
    @news = News.find(params[:id]).decorate
  end
end
