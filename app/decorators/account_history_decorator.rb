class AccountHistoryDecorator < ApplicationDecorator
  delegate_all
  decorates_association :account
  decorates_association :quick_fund
  decorates_association :income

  def amount_class
    h.amount_class(model.amount)
  end

  def display_amount
    h.nice_currency(model.amount)
  end

  def display_date
    h.nice_date(model.created_at)
  end

  def tooltip_date
    h.nice_datetime(model.created_at)
  end

  def name_with_type_and_price
    if quick_fund_id.present?
      quick_fund.try(:name_with_type_and_price)
    elsif income_id.present?
      income.try(:name_with_price)
    end
  end

  def parent_path
    if quick_fund_id.present?
      h.quick_fund_path(quick_fund_id, account_id: self.account_id, format: :json)
    elsif income_id.present?
      h.income_path(income_id, account_id: self.account_id, account_history_id: self.id, format: :json)
    end
  end

  def account_name
    account ? account.name : "Undistributed Funds"
  end
end
