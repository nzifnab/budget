require 'rails_helper'

RSpec.describe Income, type: :model do
  describe "#distribute_funds" do
    let(:catchall_account){Account.create!(
      name: "Catchall",
      add_per_month: 100,
      add_per_month_type: "%",
      priority: 5
    )}
    let(:percentage_account){Account.create!(
      name: "Percentage",
      add_per_month: 30,
      add_per_month_type: "%",
      priority: 6
    )}
    let(:flat_value_account){Account.create!(
      name: "Flat Value",
      add_per_month: 600,
      add_per_month_type: "$",
      priority: 7
    )}

    let(:user){User.new(id: 55)}
    let(:income){Income.new(user: user)}

    it 'is setup correctly' do
      expect(catchall_account).to be_valid
    end

    # This is going to go through every possible way that accounts are setup,
    # to make sure distribution is using the right orders.
    it 'will distribute all funds into a single 100% catch-all account' do
      test_distribution(
        accounts: [:catchall],
        amount: 52_948,

        expect: {
          amounts: {
            catchall: 52_948,
          },
          undistributed: 0,
          history: [52_948]
        }
      )
    end

    it 'distributes a % value into an account' do
      test_distribution(
        accounts: [:percentage],
        amount: 10_000,

        expect: {
          amounts: {
            percentage: 3_000
          },
          undistributed: 7_000,
          history: [3_000, 7_000]
        }
      )
    end

    it 'distributes a flat value into an account' do
      test_distribution(
        accounts: [:flat_value],
        amount: 4_500,

        expect: {
          amounts: {
            flat_value: 600
          },
          undistributed: 3_900,
          history: [600, 3_900]
        }
      )
    end

    def test_distribution(options)
      options[:accounts].each do |account_name|
        public_send("#{account_name}_account").tap{|a| a.user = user}.save!
      end

      income.amount = options[:amount]
      income.save!

      options[:expect][:amounts].each do |account_name, amount|
        account = public_send("#{account_name}_account")
        account.reload
        expect(account.amount).to eq(amount)
      end
      expect(income.amount).to eq(options[:amount])
      expect(user.undistributed_funds).to eq(options[:expect][:undistributed])

      history_amounts = options[:expect][:history]
      histories = income.account_histories.order(id: :asc)
      expect(histories.size).to eq(history_amounts.size)

      histories.each do |history|
        expect(history.amount).to eq(history_amounts.shift)
      end
    end
  end
end
