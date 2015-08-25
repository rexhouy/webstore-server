class Admin::ArticlesController < AdminController
        # Checks authorization for all actions using cancan
        load_and_authorize_resource except: :create

        def index
                @articles = Article.owner(owner).paginate(:page => params[:page])
        end

        def edit
                @article = Article.owner(owner).find(params[:id])
        end

        def new
                @article = Article.new
        end

        def destroy
                Article.find(params[:id]).owner(owner).destroy
                redirect_to admin_articles_path
        end

        def create
                @article = Article.new(article_param)
                authorize! :create, @article
                article.groups_id = owner
                if @article.save
                        redirect_to :action => "show", :id => @article.id
                else
                        render :new
                end
        end

        def update
                @article = Article.find(params[:id])
                if @article.update(article_param)
                        redirect_to :action => "show", :id => @article.id
                else
                        render :edit
                end
        end

        def show
                @article = Article.find_by_id(params[:id])
        end

        private
        def article_param
                params.require(:article).permit(:title, :content)
        end
end