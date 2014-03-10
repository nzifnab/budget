class AccountHistoryDecorator < ApplicationDecorator
  delegate_all
  decorates_association :account
  decorates_association :quick_fund

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
    if quick_fund_id.present? && quick_fund.present?
      quick_fund.name_with_type_and_price
    # elsif income_id.present?
    end
  end

  def parent_path
    if quick_fund_id.present? && quick_fund.present?
      h.quick_fund_path(quick_fund_id, account_id: self.account_id, format: :html)
    end
  end
end
