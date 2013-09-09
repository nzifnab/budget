require 'active_model'
class Account# < ActiveRecord::Base
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include Draper::Decoratable

  attr_accessor :name, :description, :priority, :enabled, :amount, :id, :created_at
  attr_accessor :budget

  validates :name, presence: {message: "Required"}
  validates :priority, inclusion: {in: 1..10, message: "1 to 10"}

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
    self.created_at = Time.now
    !!budget.add_account(self)
  end

  def enabled?
    !!enabled
  end

  def persisted?
    false
  end
end
