# frozen_string_literal: true

class PermissionPassesController < ApplicationController
  before_action :set_permission_pass, only: [:edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :admins_only, except: :apply

  # GET /permission_passes
  def index
    @permission_passes = PermissionPass.non_past
  end

  # GET /permission_passes/new
  def new
    @permission_pass = PermissionPass.new
  end

  # GET /permission_passes/1/edit
  def edit
  end

  # POST /permission_passes
  def create
    @permission_pass = PermissionPass.new(permission_pass_params).tap do |p|
      p.creator = current_user
    end

    if @permission_pass.save
      flash[:notice] = 'Permission pass was successfully created.'
      redirect_to permission_passes_path
    else
      render :new
    end
  end

  # PATCH/PUT /permission_passes/1
  def update
    if @permission_pass.update(permission_pass_params)
      flash[:notice] = 'Permission pass was successfully updated.'
      redirect_to permission_passes_path
    else
      render :edit
    end
  end

  # DELETE /permission_passes/1
  def destroy
    @permission_pass.destroy
    redirect_to permission_passes_path, notice: 'Permission pass was successfully destroyed.'
  end

  def apply
    @permission_pass = PermissionPass.find(params.fetch(:permission_pass_id))
    raise ActiveRecord::RecordNotFound unless @permission_pass&.current?

    if @permission_pass.apply(current_user)
      flash[:notice] = 'Permission pass abilities applied'
    else
      flash[:alert] = 'Something went wrong with the permission pass. Please contact a LittleSis administrator.'
    end

    redirect_to request.referer || '/home/dashboard'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_permission_pass
    @permission_pass = PermissionPass.find(params[:id])
  end

  def permission_pass_params
    params
      .fetch(:permission_pass)
      .permit(:event_name, :valid_from, :valid_to, :role)
  end
end
