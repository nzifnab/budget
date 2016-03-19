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
          history: [
            {
              amount: 52_948,
              explanation: "Distributed at priority level 5: 100.00% of $52,948.00"
            }
          ]
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
          history: [
            {
              amount: 3_000,
              explanation: "Distributed at priority level 6: 30.00% of $10,000.00"
            },
            {
              amount: 7_000,
              explanation: "Undistributed Funds"
            }
          ]
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
          history: [
            {
              amount: 600,
              explanation: "Distributed at priority level 7: $600.00 of $4,500.00"
            },
            {
              amount: 3_900,
              explanation: "Undistributed Funds"
            }
          ]
        }
      )
    end

    it 'distributes into higher priority before lower priority' do
      flat_value_account.update_attributes(
        priority: 3,
        cap: 450
      )
      percentage_account.update_attributes(
        priority: 7
      )


      test_distribution(
        accounts: [:flat_value, :percentage],
        amount: 1_200,

        expect: {
          amounts: {
            percentage: 360,
            flat_value: 450
          },
          undistributed: 390,
          history: [
            {
              amount: 360,
              explanation: "Distributed at priority level 7: 30.00% of $1,200.00"
            },
            {
              amount: 450,
              explanation: "Distributed at priority level 3: $600.00 of $840.00 ($450.00 cap)"
            },
            {
              amount: 390,
              explanation: "Undistributed Funds"
            }
          ]
        }
      )
    end

    it 'it distribute % values based on the priority level' do
      flat_value_account.update_attributes(
        priority: 7,
        cap: 450
      )
      percentage_account.update_attributes(
        priority: 3
      )

      test_distribution(
        accounts: [:flat_value, :percentage],
        amount: 1_200,

        expect: {
          amounts: {
            flat_value: 450,
            percentage: 225
          },
          undistributed: 525,
          history: [
            {
              amount: 450,
              explanation: "Distributed at priority level 7: $600.00 of $1,200.00 ($450.00 cap)"
            },
            {
              amount: 225,
              explanation: "Distributed at priority level 3: 30.00% of $750.00"
            },
            {
              amount: 525,
              explanation: "Undistributed Funds"
            }
          ]
        }
      )
    end

    it 'skips accounts that have a prerequisite with no cap' do
      flat_value_account.update_attributes(
        prerequisite_account: catchall_account
      )
      catchall_account.update_attributes(
        amount: 15_000
      )

      test_distribution(
        accounts: [:flat_value, :percentage, :catchall],
        amount: 2_000,

        expect: {
          amounts: {
            flat_value: 0,
            percentage: 600,
            catchall: 16_400
          },
          undistributed: 0,
          history: [
            {
              amount: 600,
              explanation: "Distributed at priority level 6: 30.00% of $2,000.00"
            },
            {
              amount: 1_400,
              explanation: "Distributed at priority level 5: 100.00% of $1,400.00"
            }
          ]
        }
      )
    end

    it 'skips accounts that have an unfulfilled prerequisite set (cap is set)' do
      flat_value_account.update_attributes(
        prerequisite_account: catchall_account
      )
      catchall_account.update_attributes(
        cap: 20_000,
        amount: 15_000
      )

      test_distribution(
        accounts: [:flat_value, :percentage, :catchall],
        amount: 2_000,

        expect: {
          amounts: {
            flat_value: 0,
            percentage: 600,
            catchall: 16_400
          },
          undistributed: 0,
          history: [
            {
              amount: 600,
              explanation: "Distributed at priority level 6: 30.00% of $2,000.00"
            },
            {
              amount: 1_400,
              explanation: "Distributed at priority level 5: 100.00% of $1,400.00"
            }
          ]
        }
      )
    end

    it 'distributes to the account if the prerequisite is fulfilled' do
      flat_value_account.update_attributes(
        prerequisite_account: catchall_account
      )
      catchall_account.update_attributes(
        cap: 1_000,
        amount: 1_100
      )

      test_distribution(
        accounts: [:flat_value, :percentage, :catchall],
        amount: 2_000,

        expect: {
          amounts: {
            flat_value: 600,
            percentage: 420,
            catchall: 1_100
          },
          undistributed: 980,
          history: [
            {
              amount: 600,
              explanation: "Distributed at priority level 7: $600.00 of $2,000.00"
            },
            {
              amount: 420,
              explanation: "Distributed at priority level 6: 30.00% of $1,400.00"
            },
            {
              amount: 980,
              explanation: "Undistributed Funds"
            }
          ]
        }
      )
    end

    it 'completes an already-started add_per_month value before moving to the next account' do
      # Adds value in the month together
      flat_value_account.account_histories.create!(
        amount: 90,
        income_id: 999
      )
      flat_value_account.account_histories.create!(
        amount: 160,
        income_id: 998
      )
      # Ignores values created in previous months
      flat_value_account.account_histories.create!(
        created_at: Time.zone.now.beginning_of_month - 1.minute,
        amount: 255,
        income_id: 997
      )
      # Ignores non-income histories
      flat_value_account.account_histories.create!(
        amount: 255,
        quick_fund_id: 800
      )

      test_distribution(
        accounts: [:flat_value, :percentage],
        amount: 700,

        expect: {
          amounts: {
            flat_value: 350,
            percentage: 105
          },
          undistributed: 245,
          history: [
            {
              amount: 350,
              explanation: "Distributed at priority level 7: $600.00 of $700.00 ($250.00 previously added this month)"
            },
            {
              amount: 105,
              explanation: "Distributed at priority level 6: 30.00% of $350.00"
            },
            {
              amount: 245,
              explanation: "Undistributed Funds"
            }
          ]
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
        expect(
          account_name => account.amount
        ).to eq(
          account_name => amount
        )
      end
      expect(
        amount: income.amount
      ).to eq(
        amount: options[:amount]
      )
      expect(
        undistributed: user.undistributed_funds
      ).to eq(
        undistributed: options[:expect][:undistributed]
      )

      history_amounts = options[:expect][:history]
      histories = income.account_histories.order(id: :asc)
      expect(
        history_size: histories.size
      ).to eq(
        history_size: history_amounts.size
      )
      histories.each do |history|
        history_hash = history_amounts.shift
        expect(history.amount).to eq(history_hash[:amount])
        expect(history.explanation).to eq(history_hash[:explanation])
      end
    end
  end
end
