class FileAttachmentsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]

  # GET /file_attachments
  # GET /file_attachments.xml
  def index
    @file_attachments = FileAttachment.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @file_attachments }
    end
  end

  # GET /file_attachments/1
  # GET /file_attachments/1.xml
  def show
    @file_attachment = FileAttachment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @file_attachment }
    end
  end

  # GET /file_attachments/new
  # GET /file_attachments/new.xml
  def new
    @file_attachment = FileAttachment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @file_attachment }
    end
  end

  # GET /file_attachments/1/edit
  def edit
    @file_attachment = FileAttachment.find(params[:id])
  end

  # POST /file_attachments
  # POST /file_attachments.xml
  def create
    @file_attachment = FileAttachment.new(params[:file_attachment])

    respond_to do |format|
      if @file_attachment.save
        flash[:notice] = 'FileAttachment was successfully created.'
        format.html { redirect_to(@file_attachment) }
        format.xml  { render :xml => @file_attachment, :status => :created, :location => @file_attachment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @file_attachment.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  

  # PUT /file_attachments/1
  # PUT /file_attachments/1.xml
  def update
    @file_attachment = FileAttachment.find(params[:id])

    respond_to do |format|
      if @file_attachment.update_attributes(params[:file_attachment])
        flash[:notice] = 'FileAttachment was successfully updated.'
        format.html { redirect_to(@file_attachment) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @file_attachment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /file_attachments/1
  # DELETE /file_attachments/1.xml
  def destroy
    @file_attachment = FileAttachment.find(params[:id])
    @file_attachment.destroy

    respond_to do |format|
      format.html { redirect_to(file_attachments_url) }
      format.xml  { head :ok }
    end
  end
end
