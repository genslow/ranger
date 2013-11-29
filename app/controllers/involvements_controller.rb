class InvolvementsController < EventBasedController
  # GET /involvements
  # GET /involvements.json
  def index
    @involvements = @involvements.where(:event_id => @event.id) if @event
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @involvements }
    end
  end

  def search
    @query = params[:q]
    if @query.blank?
      @involvements = Involvement.where('1 = 0')
      flash.notice = 'Empty search query'
    else
      @query = @query.to_ascii
      @involvements = @involvements.where(event_id: @event.id) if @event
      @involvements = @involvements.with_query(@query)
      if @involvements.none?
        flash.notice = "No people found in #{@event}"
      end
    end
    respond_to do |format|
      format.html # search.html.haml
      format.json { render json: @involvements }
    end
  end

  # GET /involvements/1
  # GET /involvements/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @involvement }
    end
  end

  # GET /involvements/new
  # GET /involvements/new.json
  def new
    @involvement.event ||= @event
    @involvement.person_id ||= params[:person_id]
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @involvement }
    end
  end

  # GET /involvements/1/edit
  def edit
  end

  # POST /involvements
  # POST /involvements.json
  def create
    respond_to do |format|
      if @involvement.save
        format.html { redirect_to @involvement, :notice => 'Involvement was successfully created.' }
        format.json { render :json => @involvement, :status => :created, :location => @involvement }
      else
        format.html { render :action => "new" }
        format.json { render :json => @involvement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /involvements/1
  # PUT /involvements/1.json
  def update
    respond_to do |format|
      if @involvement.update_attributes(params[:involvement])
        format.html { redirect_to @involvement, :notice => 'Involvement was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @involvement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /involvements/1
  # DELETE /involvements/1.json
  def destroy
    @involvement.destroy

    respond_to do |format|
      format.html { redirect_to involvements_url }
      format.json { head :no_content }
    end
  end

  def signup
    authorize! :update, @involvement
    if @involvement.positions.empty?
      @slots = []
    else
      @slots = @event.slots.where(:position_id => @involvement.position_ids)
    end
    respond_to do |format|
      format.html { render :action => "signup" }
      format.json { head :no_content }
    end
  end

  def subject_record
    @involvement
  end
end
