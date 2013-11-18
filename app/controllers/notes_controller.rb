class NotesController < ApplicationController
  before_action :set_note, only: [:show, :edit, :update, :destroy]

  # GET /notes
  def index
    check_permission "admin"
    @notes = Note.all
  end

  # GET /notes/1
  def show
  end

  # GET /notes/new
  def new
    @note = Note.new
    default_body = []
    if params[:reply_to].present?
      if (@reply_to_note = Note.find(params[:reply_to])).present?
        default_body += @reply_to_note.all_users.collect { |u| "@" + u.username }
        default_body += @reply_to_note.groups.collect { |g| "@" + g.slug }
        @note.is_private if @reply_to_note.is_private
      end
    end

    if params[:user].present?
      default_body += ["@" + params[:user]]
    end

    if params[:group].present?
      default_body += ["@" + params[:group]]
    end

    @note.body = default_body.uniq.join(" ") unless default_body.blank?
  end

  # GET /notes/1/edit
  def edit
    check_permission "admin"
  end

  # POST /notes
  def create
    @note = Note.new(note_params)

    if @note.save
      redirect_to @note, notice: 'Note was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /notes/1
  def update
    check_permission "admin"
    if @note.update(note_params)
      redirect_to @note, notice: 'Note was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /notes/1
  def destroy
    @note.destroy
    redirect_to home_notes_path, notice: 'Note was successfully destroyed.'
  end

  def user
    @user = User.includes(:notes, notes: [:user, :recipients]).find_by_username(params[:username])
    @notes = @user.notes_with_replies.page(params[:page]).per(20)

    # @user.notes.order("created_at DESC").page(params[:page]).per(20)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_note
      @note = Note.includes(:recipients, :entities, :relationships, :lists, :groups, :networks).find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def note_params
      params.require(:note).permit(:body, :is_private, :reply_to, :group, :page)
    end
end
