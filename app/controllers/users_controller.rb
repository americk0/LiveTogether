# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  username               :string
#  password_digest        :string
#  name                   :string
#  isNewser               :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  forem_admin            :boolean          default(FALSE)
#  forem_state            :string           default("pending_review")
#  forem_auto_subscribe   :boolean          default(FALSE)
#

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  def forem_name
    email_address
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    @user.score = 0

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        unless @user.phone_number.nil? || @user.phone_number.match(/^[0-9]{3}[-.]?[0-9]{3}[-.]?[0-9]{4}$/)
          @user.phone_number = nil
          @user.save!
        end
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    if @user.user_type != 'admin'
      @user.destroy
    end

    respond_to do |format|
      if current_user.user_type == 'admin'
        format.html { redirect_to admin_url, notice: 'User was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { redirect_to root_url, notice: 'User was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:username, :password, :email, :phone_number, :description, :name, :user_type, :image_url)
    end
end
