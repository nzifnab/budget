require 'active_model'
class Account# < ActiveRecord::Base
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include Draper::Decoratable

  attr_accessor :name, :description, :priority, :enabled, :amount, :id
  attr_accessor :budget

  validates :name, presence: true

  def initialize(attrs={})
    attrs.each do |k,v| send("#{k}=", v) end
    self.amount ||= 0
  end

  def priority
    @priority ? @priority.to_i : @priority
  end

  def enabled
    if @enabled == "1"
      true
    elsif @enabled == "0"
      false
    else
      @enabled
    end
  end

  def submit
    return false unless valid?
    !!budget.add_account(self)
  end

  def enabled?
    !!enabled
  end

  def persisted?
    false
  end
end
