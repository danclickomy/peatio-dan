module Admin
  module Deposits
    class SikretsController < ::Admin::Deposits::BaseController
      load_and_authorize_resource :class => '::Deposits::Sikret'

      def index
        start_at = DateTime.now.ago(60 * 60 * 24 * 365)
        @sikrets = @sikrets.includes(:member).
          where('created_at > ?', start_at).
          order('id DESC').page(params[:page]).per(20)
      end

      def update
        @sikret.accept! if @sikret.may_accept?
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end


