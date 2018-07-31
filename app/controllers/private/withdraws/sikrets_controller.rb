module Private::Withdraws
  class SikretsController < ::Private::Withdraws::BaseController
    include ::Withdraws::Withdrawable
  end
end
