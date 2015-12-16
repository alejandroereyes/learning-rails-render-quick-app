class WidgetsController < ApplicationController
  before_action :set_widget, only: [:show, :edit, :update, :destroy]
  respond_to :html, :xlsx, :json

  # GET /widgets
  def index
    @widgets = Widget.all
    case params[:render]
    when 'with_extension'
      render 'index.xlsx.axlsx' #always xlsx
    when 'with_format'
      render 'index', formats: [:xlsx] #always xlsx
    when 'render_xlsx'
      render xlsx: @widgets
      render json: @widgets
    when 'respond_with'
      respond_with @widgets
    when 'with_filename'
      # response.headers['Content-Disposition'] =
        # 'attachment; filename="with_filename.xlsx"'
      # send_data render_to_string, :filename => 'with_filename.xlsx', :type => Mime::XLSX, :disposition => 'attachment'
      render xlsx: 'with_filename'
    else
      # default_render
    end
  end

  def with
    @widgets = Widget.all
    respond_with @widgets
  end

  def xlsx
    WidgetMailer.to_xlsx(Widget.all).deliver
    render json: true
  end

  # GET /widgets/1
  def show
  end

  # GET /widgets/new
  def new
    @widget = Widget.new
  end

  # GET /widgets/1/edit
  def edit
  end

  # POST /widgets
  def create
    @widget = Widget.new(widget_params)

    if @widget.save
      redirect_to @widget, notice: 'Widget was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /widgets/1
  def update
    if @widget.update(widget_params)
      redirect_to @widget, notice: 'Widget was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /widgets/1
  def destroy
    @widget.destroy
    redirect_to widgets_url, notice: 'Widget was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_widget
      @widget = Widget.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def widget_params
      params.require(:widget).permit(:name, :description)
    end
end
