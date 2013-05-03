class OpportunitiesController < ApplicationController
  before_filter :login_required
  
  def login_required
    session[:return_to] = request.fullpath
    if session[:user_id]
      @current_user = User.find(session[:user_id])
    else
      redirect_to '/auth/salesforce'
    end
  end
  def index
    # Variables that store totals for Opportunities won and lost
    opportunities_won_total  = Opportunity.sum(:amount, :conditions => ['stage = \'Closed Won\''])
    opportunities_lost_total = Opportunity.sum(:amount, :conditions => ['stage = \'Closed Lost\''])

    # Pie chart of total won vs lost Opportunities
    @chart_by_total = GChart.pie3d do |g|
      g.title = "Opportunities Overall"
      g.data = [opportunities_won_total, opportunities_lost_total]
      g.colors = ["00FF00,FF0000"]
      g.legend = ["Won","Lost"]
      g.width  = 350
    end

    # Array variables that store sum total Opportunities won or lost for each year
    opportunities_won_year  = Opportunity.select("date_part('year', closed_on) as year, sum(amount) as total").group("date_part('year', closed_on)").where('stage = \'Closed Won\'').order("year")
    opportunities_lost_year = Opportunity.select("date_part('year', closed_on) as year, sum(amount) as total").group("date_part('year', closed_on)").where('stage = \'Closed Lost\'').order("year")

    # Variables to get max and min totals for setting graph axis range
    owm = opportunities_won_year.max_by{ |o| o.total.to_i }.total.to_i
    owl = opportunities_lost_year.max_by{ |o| o.total.to_i }.total.to_i

    ow = [owm, owl].max

    # Line chart, won vs lost, by year
    @chart_by_year = GChart.line do |g|
      g.title = "Opportunities by Year"
      g.data  = [
        opportunities_won_year.flat_map(&:total).collect{|i| i.to_i},
        opportunities_lost_year.flat_map(&:total).collect{|i| i.to_i}
      ]
      g.colors = [:green, :red]
      g.legend = ["Won", "Lost"]

      g.width  = 450

      g.axis(:left) do |a|
        a.range = 0..ow
      end

      g.axis(:bottom) do |a|
        a.labels = [opportunities_won_year.flat_map(&:year).join('|')]
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @opportunities }
    end
  end

  # GET /opportunities/1
  # GET /opportunities/1.json
  def show
    @opportunity = Opportunity.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @opportunity }
    end
  end

  # GET /opportunities/new
  # GET /opportunities/new.json
  def new
    @opportunity = Opportunity.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @opportunity }
    end
  end

  # GET /opportunities/1/edit
  def edit
    @opportunity = Opportunity.find(params[:id])
  end

  # POST /opportunities
  # POST /opportunities.json
  def create
    @opportunity = Opportunity.new(params[:opportunity])

    respond_to do |format|
      if @opportunity.save
        format.html { redirect_to @opportunity, notice: 'Opportunity was successfully created.' }
        format.json { render json: @opportunity, status: :created, location: @opportunity }
      else
        format.html { render action: "new" }
        format.json { render json: @opportunity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /opportunities/1
  # PUT /opportunities/1.json
  def update
    @opportunity = Opportunity.find(params[:id])

    respond_to do |format|
      if @opportunity.update_attributes(params[:opportunity])
        format.html { redirect_to @opportunity, notice: 'Opportunity was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @opportunity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /opportunities/1
  # DELETE /opportunities/1.json
  def destroy
    @opportunity = Opportunity.find(params[:id])
    @opportunity.destroy

    respond_to do |format|
      format.html { redirect_to opportunities_url }
      format.json { head :no_content }
    end
  end
end
