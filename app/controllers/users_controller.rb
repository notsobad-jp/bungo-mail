class UsersController < ApplicationController
  before_action :require_login
  before_action :set_user
  after_action :verify_authorized

  def show
    @breadcrumbs << {name: 'アカウント情報'}
  end

  private
    def set_user
      @user = User.find_by_token(params[:token])
      authorize @user
    end
end
