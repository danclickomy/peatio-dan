module Admin
  module Withdraws
    class SikretsController < ::Admin::Withdraws::BaseController
      load_and_authorize_resource :class => '::Withdraws::Sikret'

      def index
        start_at = DateTime.now.ago(60 * 60 * 24)
        @one_sikrets = @sikrets.with_aasm_state(:accepted).order("id DESC")
        @all_sikrets = @sikrets.without_aasm_state(:accepted).where('created_at > ?', start_at).order("id DESC")
      end

      def show
      end

      def update
        @sikret.process!
        redirect_to :back, notice: t('.notice')
      end

      def destroy
        @sikret.reject!
        redirect_to :back, notice: t('.notice')
      end
    end
  end
end
