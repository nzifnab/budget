class AccountHistoryDecorator < Draper::Decorator
  delegate_all
  decorates_association :account
end
