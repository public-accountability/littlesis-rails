class NotesController < ApplicationController
  before_filter :auth, except: [:show, :user, :index]
  before_action :set_note, only: [:show, :edit, :update, :destroy]

  # GET /notes
  def index
    if params[:q].present?
      if user_signed_in?
        @notes = Note.search(
          Riddle::Query.escape(params[:q]), 
          order: "created_at DESC", 
          with: { visible_to_user_ids: [0, current_user.id] }
        ).page(params[:page]).per(20)
      else
        @notes = Note.search(
          Riddle::Query.escape(params[:q]), 
          order: "created_at DESC", 
          with: { is_private: false }
        ).page(params[:page]).per(20)
      end
    else
      @notes = Note.visible_to_user(current_user).page(params[:page]).per(20)
    end
  end

  # GET /notes/1
  def show
    not_found if @note.blank?
    raise Exceptions::PermissionError unless @note.visible_to?(current_user)
  end

  # GET /notes/new
  def new
    @note = Note.new
    default_body = []

    if params[:reply_to].present?
      if (@reply_to_note = Note.find(params[:reply_to])).present?
        default_body += @reply_to_note.all_users.collect { |u| "@" + u.username }
        default_body += @reply_to_note.groups.collect { |g| "@group:" + g.slug }
        @note.is_private if @reply_to_note.is_private
      end
    end

    if params[:user].present?
      default_body += ["@" + params[:user]]
    end

    if params[:group].present?
      default_body += ["@group:" + params[:group]]
    end

    @note.body_raw = default_body.uniq.join(" ") unless default_body.blank?
  end

  # GET /notes/1/edit
  def edit
    check_permission "admin"
  end

  # POST /notes
  def create
    @note = Note.new(note_params)
    @note.body = "" # placeholder until set during view render
    @note.is_legacy = false
    @note.user = current_user
    @note.network_ids = [@note.user.default_network_id]
    @note.parse
    @note.legacy_denormalize

    if @note.save
      @note.clear_related_cache

      if params[:redirect_to]
        redirect_to params[:redirect_to], notice: 'Note was successfully created', flash: { new_note_id: @note.id }
      else
        redirect_to home_notes_path, notice: 'Note was successfully created.', flash: { new_note_id: @note.id }
      end
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
    @note.clear_related_cache
    redirect_to home_notes_path, notice: 'Note was successfully deleted.'
  end

  def user
    @user = User.find_by_username(params[:username])
    not_found if @user.blank?
    redirect_to home_notes_path if user_signed_in? and current_user.id == @user.id

    @show_replies = (params[:show_replies].present? and params[:show_replies] == "1")

    if @show_replies
      @notes = @user.notes_with_replies_visible_to_user(current_user).page(params[:page]).per(20)
    else
      if params[:q].present?
        if user_signed_in?
          @notes = Note.search(
            Riddle::Query.escape(params[:q]), 
            order: "created_at DESC", 
            with: { user_id: @user.id, visible_to_user_ids: [0, current_user.id] }
          ).page(params[:page]).per(20)
        else
          @notes = Note.search(
            Riddle::Query.escape(params[:q]), 
            order: "created_at DESC", 
            with: { user_id: @user.id, is_private: false }
          ).page(params[:page]).per(20)
        end
      else
        @notes = @user.notes_visible_to_user(current_user).page(params[:page]).per(20)
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_note
      @note = Note.includes(:recipients, :entities, :relationships, :lists, :groups, :networks).find(params[:id])

      if params[:username].present?
        not_found unless @note.user.username == params[:username]
      end
    end

    # Only allow a trusted parameter "white list" through.
    def note_params
      params.require(:note).permit(:body_raw, :is_private)
    end
end
