class NewsController < ResourceController
  cache_actions :index, :show

  def index
    @news = News.all.index_order.decorate
  end

  def show
    @news = News.find(params[:id]).decorate
    @page_title = "#{@news} (#{l(@news.published_at, format: :only_date)}) - Neuigkeit"
  end
end
