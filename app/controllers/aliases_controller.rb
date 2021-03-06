

class AliasesController < ApplicationController
  before_action :set_alias, only: [:show, :edit, :update, :destroy]
  before_action :forward_search_params

  # GET /aliases
  # GET /aliases.json
  def index
    @search = params[:search] || nil
    if @search.present?
      @aliases = Alias.search(@search).accessible_by(current_ability).includes(:email_virtual_domain)
    end
    authorize! :read, Alias
  end

  # GET /aliases/1
  # GET /aliases/1.json
  def show
    authorize! :read, @alias
  end

  # GET /aliases/new
  def new
    @alias = Alias.new
    authorize! :create, @alias
    @evd = EmailVirtualDomain.order(:name)
    @ml = Ml::List.all.order(:email)
  end

  # GET /aliases/1/edit
  def edit
    authorize! :update, @alias
    @evd = EmailVirtualDomain.all
    @ml = Ml::List.all.order(:email)
  end

  # POST /aliases
  # POST /aliases.json
  def create
    @alias = Alias.new(alias_params)
    authorize! :create, @alias

    respond_to do |format|
      if @alias.save
        format.html { redirect_to alias_path(@alias, search: @search), notice: 'Alias was successfully created.'}
        format.json { render :show, status: :created, location: @alias}
      else
        format.html { render :new, search: @search }
        format.json { render json: @alias.errors, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /aliases/1
  # PATCH/PUT /aliases/1.json
  def update
    authorize! :update, @alias
    respond_to do |format|
      if @alias.update(alias_params)
        format.html { redirect_to alias_path(@alias, search: @search), notice: 'Alias was successfully updated.'}
        format.json { render :show, status: :ok, location: @alias}
      else
        format.html { render :edit, search: @search }
        format.json { render json: @alias.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /aliases/1
  # DELETE /aliases/1.json
  def destroy
    authorize! :destroy, @alias
    @alias.destroy
    respond_to do |format|
      format.html { redirect_to aliases_path(@alias, search: @search), notice: 'Alias was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_alias
      @alias = Alias.find(params[:id])
    end
  def forward_search_params
    @search = params[:search] || ""
  end

    # Never trust parameters from the scary internet, only allow the white list through.
    def alias_params
      params.require(:alias).permit(:email, :redirect, :email_virtual_domain_id, :list_id)

    end
end
