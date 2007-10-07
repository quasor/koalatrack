class TagFavoritesController < ApplicationController
  # GET /tag_favorites
  # GET /tag_favorites.xml
  def index
    @tag_favorites = TagFavorite.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tag_favorites }
    end
  end

  # GET /tag_favorites/1
  # GET /tag_favorites/1.xml
  def show
    @tag_favorite = TagFavorite.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tag_favorite }
    end
  end

  # GET /tag_favorites/new
  # GET /tag_favorites/new.xml
  def new
    @tag_favorite = TagFavorite.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tag_favorite }
    end
  end

  # GET /tag_favorites/1/edit
  def edit
    @tag_favorite = TagFavorite.find(params[:id])
  end

  # POST /tag_favorites
  # POST /tag_favorites.xml
  def create
    @tag = Tag.find_or_create_by_name(params[:tag]) unless params[:tag].nil? or params[:tag].blank?
    @tag_favorite = TagFavorite.new(:tag_id => @tag.id)

    respond_to do |format|
      if @tag_favorite.save
        flash[:notice] = 'TagFavorite was successfully created.'
        format.html { redirect_to(tag_favorites_url) }
        format.xml  { render :xml => @tag_favorite, :status => :created, :location => @tag_favorite }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tag_favorite.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tag_favorites/1
  # PUT /tag_favorites/1.xml
  def update
    @tag_favorite = TagFavorite.find(params[:id])

    respond_to do |format|
      if @tag_favorite.update_attributes(params[:tag_favorite])
        flash[:notice] = 'TagFavorite was successfully updated.'
        format.html { redirect_to(@tag_favorite) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tag_favorite.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tag_favorites/1
  # DELETE /tag_favorites/1.xml
  def destroy
    @tag_favorite = TagFavorite.find(params[:id])
    @tag_favorite.destroy

    respond_to do |format|
      format.html { redirect_to(tag_favorites_url) }
      format.xml  { head :ok }
    end
  end
end
