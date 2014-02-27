class QuickFundDecorator < Draper::Decorator
  delegate_all
  decorates_association :account_histories
end
