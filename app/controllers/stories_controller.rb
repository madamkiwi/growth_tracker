class StoriesController < ApplicationController
  skip_before_filter  :verify_authenticity_token
  respond_to :json

  def index
    if (current_user)
      @stories = Story.active.where(user_id: current_user.id)
    else
      @stories = Story.active.published
    end
    render json: @stories, except: [:created_at, :updated_at]
  end

  def featured
    @stories = Story.published.featured.active
    render json: @stories, except: [:created_at, :updated_at]
  end

  def destroy
    @story = Story.find_by_id(params[:id])
    @story.archived = true
    @story.save
    render json: @story, except: [:created_at, :updated_at]
  end

  def show
    @story = Story.find_by_id(params[:id])
    render json: @story, except: [:created_at, :updated_at]
  end

  def create
      @story = Story.new(story_params)
      @story.user_id = current_user.id
      @story.archived = false
      @story.featured = false
      @story.published = false
      @story.save
      render json: @story, except: [:created_at, :updated_at]
  end

  def update
      @story = Story.find_by_id(params[:id])
      byebug
      @tag = Tag.find_by(hashtags: params[:hashtag])
      if @tag == nil
        @tag = Tag.new(hashtags: params[:hashtag])
        @tag.save
      end
      @story_tag = StoryTag.new(story_id: params[:id], tag_id: @tag.id)
      @story_tag.save
      @story.title = params[:title]
      @story.text = params[:text]
      @story.featured = params[:featured]
      @story.published = params[:published]
      @story.save
      render json: @story, except: [:created_at, :updated_at]
  end

  private
    def story_params
      params.require(:story).permit(:title, :text)
    end

end
