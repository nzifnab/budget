class Account# < ActiveRecord::Base
  #extend ActiveModel::Naming
  #include ActiveModel::Conversion
  include Draper::Decoratable

  attr_accessor :name, :description, :priority, :enabled, :amount
  attr_accessor :budget

  def initialize(attrs={})
    attrs.each do |k,v| send("#{k}=", v) end
    self.amount ||= 0
  end

  def submit
    budget.add_account(self)
  end

  def enabled?
    !!enabled
  end

  #def persisted?
  #  false
  #end
end
