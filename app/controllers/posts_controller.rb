class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy, :order, :buy, :admin]
  before_action :authenticate_user!, except: :index
  load_and_authorize_resource
  def index
    if params[:tag]
      @posts = Post.tagged_with(params[:tag]).order(created_at: :desc).page(params[:page]).per(5)
    else
      @posts = Post.order(created_at: :desc).page(params[:page]).per(5)
    end
    respond_to do |format|
      format.html
      format.json { render json: @posts }
    end
  end

  def mypage
    if params[:tag]
      @myposts = current_user.posts.tagged_with(params[:tag]).order(created_at: :desc).first(4)
      @likeposts = current_user.liked_posts.tagged_with(params[:tag]).order(created_at: :desc).first(4)
    else
      @myposts = current_user.posts.order(created_at: :desc).first(4)
      @likeposts = current_user.liked_posts.order(created_at: :desc).first(4)
    end
    respond_to do |format|
      format.html
      format.json { render json: @posts }
    end
  end

  def admin
    @orderlist=Order.order(created_at: :asc)
  end


  def group
      if params[:tag]
        @posts = Post.tagged_with(params[:tag]).order(created_at: :desc).page(params[:page]).per(12)
      else
        @posts = Post.order(created_at: :desc).page(params[:page]).per(12)
      end
      respond_to do |format|
        format.html
      end
   end

  def rank
      @rank = Dummyrank.order(created_at: :asc).limit(10)
      #수정해야함 일단 예시로 담음
  end

  def order
      @options = params[:option]
      @quantity = params[:quan]
      # puts @options
      # puts @quantity
      @result = Hash.new

      @options.each do |key,val|
        @result[val]=0
      end

      keys = @result.keys

      @quantity.each_with_index do |(key,val),i|
        @result[keys[i]] = val
      end
  end

  def buy
    @orderform=Order.new
    @orderform.rcp_name = params[:rcp_name]
    @orderform.rcp_email = params[:rcp_email]
    @orderform.del_tel_num = params[:tel1]+params[:tel2]+params[:tel3]
    @orderform.del_addr = params[:del_addr]
    @orderform.detail_addr = params[:detail_addr]
    @orderform.del_msg = params[:dmessage]
    @orderform.post_code = params[:post_code]
    @orderform.total_pay = @post.price * 5    #여기 옵션 갯수넘어오는거 받아서 다시처리
    @orderform.del_pay = 2500
    @orderform.or_time = Date.today
    @orderform.pay_time = Date.today
    @orderform.amount = params[:amount]
    @orderform.invoice_code = params[:invoice_code]
    @orderform.save

  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.new(post_params)
    #@tags = params[:tags][:content].gsub(' ','').split("#")  #이미배열
    # @tags = ["#안녕, "#방탄소년단"]

    #Tag.create(content: @tags)
    #Tag.create(content: params[:tags][:content])

    respond_to do |format|
      if @post.save
        # @tags.each do |tag|
        #    # puts tag unless tag.empty?
        #    # Tag에 있는지 없는지 찾고
        #    unless tag.empty?
        #      @tag = Tag.find_or_create_by(content: tag)
        #      # PostsTag에 post id랑 tag id를 저장한다.
        #      PostsTag.create(post_id: @post.id ,tag_id: @tag.id)
        #   end
        # end

        # 저장이 되었을 경우에 실행
        # flash[:notice] = "글 작성이 완료되었습니다."
        # redirect_to '/'
        format.html { redirect_to '/', notice: '글 작성완료!' }
      else
        # 저장이 실패했을 경우에(validation) 걸렸을 때 실행
        # flash[:alert] = "글 작성이 실패했습니다."
        # redirect_to new_post_path
        format.html { render :new }
        format.json { render json: @post.errors }
      end
    end
  end

  def show
    @comments = @post.comments
    @option = [];
    if @post.option != nil
      @option = @post.option.gsub(' ','').split('/')
    else
      @option.push(@post.title)
    end

  end

  def edit
    # @hashtags = @post.to_hashtags
  end

  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html {redirect_to @post, notice: '글 수정완료!'}
      else
        format.html { render :edit }
        format.json { render json: @post.error }
      end
    end
  end

  def destroy
    @post.destroy
    redirect_to "/"
  end

  private
  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content, :img , :account, :option, :account_name, :goal, :price, :start_date, :end_date, :description, :tag_list_fixed
                                  ) #넘어오는 파람 허가
    # params.require(:post).permit(:title, :content, :img , :start_date, :end_date, :description, tags_attributes: [:content]) #넘어오는 파람 허가
  end
end
