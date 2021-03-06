class Api::ProductsController < ApiController

        def index
                @recommendProducts = Product.recommend.available.valid.all
                render layout: false
        end

        def show
                @product = Product.find(params[:id])
                render layout: false
        end

        def all
                products = Product.available.valid.paginate(:page => params[:page])
                render json: products
        end

end
