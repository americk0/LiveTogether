# == Schema Information
#
# Table name: events
#
#  id          :integer          not null, primary key
#  name        :string
#  description :text
#  date        :date
#  location    :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /events
  # GET /events.json
  def index
    if current_user.current_neighborhood.nil?
      flash[:notice] = "Cannot view posts: No neighborhood is currently active"
      redirect_to neighborhoods_url
    end

    if current_user.current_neighborhood.nil?
      @events = nil
    else
      @events = current_user.current_neighborhood.events.where(status: 'accepted').to_a
      parent = current_user.current_neighborhood.parent
      until parent.nil?
        parent_events = parent.events.where(status: 'accepted').to_a
        parent_events.each do |event|
          if isNewser(event.user)
            @events.push(event)
          end
        end
        parent = parent.parent
      end
      @events.sort! {|left, right| right.start_time <=> left.start_time}
    end

    @pendings = Event.where(neighborhood: current_user.current_neighborhood, status: 'pending', user_id: current_user.id)

    @event = Event.new
    @current_month = Time.now.strftime("%m").to_i
    @current_year = Time.now.strftime("%m").to_i
  end

  # GET /events/1
  # GET /events/1.json
  def show
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params)
    @event.user = current_user
    @event.neighborhood = current_user.current_neighborhood

    if isNewser(current_user)
      @event.status = 'pending'

      @request = Request.new()
      @request.user = current_user
      @request.neighborhood = current_user.current_neighborhood
      @request.event = @event
      @event.request = @request
      @request.request_type = 'event'

      respond_to do |format|
        if @event.save && @request.save
          format.html { redirect_to @event, notice: 'Event was successfully requested.' }
          format.json { render :show, status: :created, location: @event }
        else
          format.html { render :new }
          format.json { render json: @event.errors, status: :unprocessable_entity }
        end
      end
    else
      @event.status = 'accepted'

      respond_to do |format|
        if @event.save
          format.html { redirect_to events_url, notice: 'Event was successfully created.' }
          format.json { render :show, status: :created, location: @event }
        else
          format.html { redirect_to events_url }
          format.json { render json: @event.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { redirect_to @event }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:name, :description, :start_time, :location)
    end
end
