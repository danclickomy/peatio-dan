module Private
  module Deposits
    class SikretsController < ::Private::Deposits::BaseController
      include ::Deposits::CtrlCoinable
    end
  end
end


