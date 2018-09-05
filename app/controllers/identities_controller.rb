class IdentitiesController < ApplicationController
  before_filter :auth_anybody!, only: :new

  def new
    @identity = env['omniauth.identity'] || Identity.new

    unless params[:ref].nil?
      if cookies[:my_ref_id] != params[:ref]
        increment_visitor_count(params[:ref])
      end
      cookies[:my_ref_id] = {:value => params[:ref], :expires => 1.month.from_now}
    end

    $my_ref_id = cookies[:my_ref_id]
  end

  def edit
    @identity = current_user.identity
  end

  def update
    @identity = current_user.identity

    unless @identity.authenticate(params[:identity][:old_password])
      redirect_to edit_identity_path, alert: t('.auth-error') and return
    end

    if @identity.authenticate(params[:identity][:password])
      redirect_to edit_identity_path, alert: t('.auth-same') and return
    end

    if @identity.update_attributes(identity_params)
      current_user.send_password_changed_notification
      clear_all_sessions current_user.id
      reset_session
      redirect_to signin_path, notice: t('.notice')
    else
      render :edit
    end
  end

  private

  def identity_params
    params.required(:identity).permit(:password, :password_confirmation)
  end

  def increment_visitor_count(my_ref_id)
    begin
      referred_by_identity = IdentityReferrer.find_by_my_ref_id(my_ref_id).identity_id
      referral_to_increment = Referral.find_by_identity_id(referred_by_identity)

      referral_to_increment.nil?
      referral_to_increment.update_attribute(:visitor_count, referral_to_increment.visitor_count + 1)

    rescue
      return
    end

  end

end
