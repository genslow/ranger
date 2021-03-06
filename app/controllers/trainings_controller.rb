class TrainingsController < EventBasedController
  # GET /trainings
  # GET /trainings.json
  def index
    @trainings = policy_scope(Training)
    @trainings = @trainings.includes(:shift)
    @trainings = @trainings.where('shifts.event_id = ?', @event.id)
    @trainings = order_by_params @trainings

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @trainings }
    end
  end

  # GET /trainings/1
  # GET /trainings/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @training }
    end
  end

  # GET /trainings/new
  # GET /trainings/new.json
  def new
    @training = Training.new
    @training.build_shift.event = @event
    if params[:date].present? and d = Time.zone.parse(params[:date])
      @training.shift.end_time = @training.shift.start_time = d
    end
    if params[:template].present? and t = ShiftTemplate.find(params[:template])
      @shift_template = t
      @training.shift.merge_from_template! t, params[:date]
    end
    authorize @training

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @training }
    end
  end

  # GET /trainings/1/edit
  def edit
  end

  # POST /trainings
  # POST /trainings.json
  def create
    @training = Training.new training_params
    @training.shift = @event.shifts.build unless @training.shift
    @training.shift.event ||= @event
    @training.shift.training = @training
    authorize @training

    respond_to do |format|
      if @training.save
        if params[:template].present? and t = ShiftTemplate.find(params[:template])
          @shift_template = t
          @training.shift.create_slots_from_template t
        end
        format.html { redirect_to [@event, @training], :notice => 'Training was successfully created.' }
        format.json { render :json => @training, :status => :created, :location => @training }
      else
        format.html { render :action => "new" }
        format.json { render :json => @training.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /trainings/1
  # PUT /trainings/1.json
  def update
    respond_to do |format|
      if @training.update_attributes(training_params)
        format.html { redirect_to [@event, @training], :notice => 'Training was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @training.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /trainings/1
  # DELETE /trainings/1.json
  def destroy
    @training.destroy

    respond_to do |format|
      format.html { redirect_to event_trainings_url(@event) }
      format.json { head :no_content }
    end
  end

  def subject_record
    @training
  end

  def load_subject_record_by_id
    @training = Training.find(params[:id])
  end

  def default_sort_column
    'shifts.start_time'
  end

  private
  def training_params
    params.require(:training).
      permit(*policy(@training || Training).permitted_attributes)
  end
end
