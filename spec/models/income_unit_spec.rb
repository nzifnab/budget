require 'rails_helper'

RSpec.describe Income, type: :model do
  describe "#distribute_funds" do
    let(:catchall_account){Account.create!(
      name: "Catchall",
      add_per_month: 100,
      add_per_month_type: "%",
      priority: 5,
      enabled: true
    )}
    let(:percentage_account){Account.create!(
      name: "Percentage",
      add_per_month: 30,
      add_per_month_type: "%",
      priority: 6,
      enabled: true
    )}
    let(:flat_value_account){Account.create!(
      name: "Flat Value",
      add_per_month: 600,
      add_per_month_type: "$",
      priority: 7,
      enabled: true
    )}
    let(:overflow_to_percent_account){Account.create!(
      name: "Overflow to Percent",
      cap: 450,
      add_per_month: 300,
      add_per_month_type: "$",
      priority: 4,
      overflow_into_account: percentage_account,
      enabled: true
    )}
    let(:overflow_to_flat_account){Account.create!(
      name: "Overflow to Flat",
      cap: 400,
      monthly_cap: 200,
      add_per_month: 25,
      add_per_month_type: "%",
      priority: 3,
      overflow_into_account: flat_value_account,
      enabled: true
    )}
    let(:double_overflow_account){Account.create!(
      name: "Double Overflow",
      cap: 1_000,
      add_per_month: 700,
      add_per_month_type: "$",
      priority: 2,
      overflow_into_account: overflow_to_flat_account,
      enabled: true
    )}

    let(:final_account){Account.create!(
      name: "Final",
      add_per_month: 8_000,
      add_per_month_type: "$",
      priority: 1,
      enabled: true
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
              explanation: "Distributed at priority level 5: 100.00% per month of $52,948.00 funds"
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
              explanation: "Distributed at priority level 6: 30.00% per month of $10,000.00 funds"
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
              explanation: "Distributed at priority level 7: $600.00 per month of $4,500.00 funds"
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
              explanation: "Distributed at priority level 7: 30.00% per month of $1,200.00 funds"
            },
            {
              amount: 450,
              explanation: "Distributed at priority level 3: $600.00 per month of $840.00 funds ($450.00 cap)"
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
              explanation: "Distributed at priority level 7: $600.00 per month of $1,200.00 funds ($450.00 cap)"
            },
            {
              amount: 225,
              explanation: "Distributed at priority level 3: 30.00% per month of $750.00 funds"
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
              explanation: "Distributed at priority level 6: 30.00% per month of $2,000.00 funds"
            },
            {
              amount: 1_400,
              explanation: "Distributed at priority level 5: 100.00% per month of $1,400.00 funds"
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
              explanation: "Distributed at priority level 6: 30.00% per month of $2,000.00 funds"
            },
            {
              amount: 1_400,
              explanation: "Distributed at priority level 5: 100.00% per month of $1,400.00 funds"
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
              explanation: "Distributed at priority level 7: $600.00 per month of $2,000.00 funds"
            },
            {
              amount: 420,
              explanation: "Distributed at priority level 6: 30.00% per month of $1,400.00 funds"
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
              explanation: "Distributed at priority level 7: $600.00 per month of $700.00 funds ($250.00 previously added this month)"
            },
            {
              amount: 105,
              explanation: "Distributed at priority level 6: 30.00% per month of $350.00 funds"
            },
            {
              amount: 245,
              explanation: "Undistributed Funds"
            }
          ]
        }
      )
    end

    it 'obeys the monthly_cap value for % distribution' do
      # Adds value in the month together
      percentage_account.account_histories.create!(
        amount: 50,
        income_id: 999
      )
      percentage_account.account_histories.create!(
        amount: 35,
        income_id: 998
      )
      # Ignores values created in previous months
      percentage_account.account_histories.create!(
        created_at: Time.zone.now.beginning_of_month - 1.minute,
        amount: 45,
        income_id: 997
      )
      # Ignores non-income histories
      percentage_account.account_histories.create!(
        amount: 82,
        quick_fund_id: 800
      )
      percentage_account.update_attributes(
        amount: 10,
        monthly_cap: 115
      )

      test_distribution(
        accounts: [:percentage, :catchall],
        amount: 300,

        expect: {
          amounts: {
            percentage: 40,
            catchall: 270
          },
          undistributed: 0,
          history: [
            {
              amount: 30,
              explanation: "Distributed at priority level 6: 30.00% per month of $300.00 funds ($115.00 monthly cap)"
            },
            {
              amount: 270,
              explanation: "Distributed at priority level 5: 100.00% per month of $270.00 funds"
            }
          ]
        }
      )
    end

    it 'obeys the yearly cap for % and flat accounts' do
      # Adds value in the month together
      Timecop.freeze("March 3, 2016".to_datetime) do
        flat_value_account.account_histories.create!(
          amount: 90,
          income_id: 999
        )
        flat_value_account.account_histories.create!(
          amount: 160,
          income_id: 998
        )

        # Not Counted
        flat_value_account.account_histories.create!(
          created_at: Time.zone.now.beginning_of_year - 1.minute,
          income_id: 997,
          amount: 249
        )

        percentage_account.account_histories.create!(
          amount: 50,
          income_id: 999
        )
        percentage_account.account_histories.create!(
          amount: 77,
          income_id: 998
        )

        # Not Counted
        percentage_account.account_histories.create!(
          amount: 35,
          quick_fund_id: 44
        )

        flat_value_account.update_attributes(
          annual_cap: 650,
          monthly_cap: 450
        )
        percentage_account.update_attributes(
          annual_cap: 200,
          monthly_cap: 150
        )
      end

      Timecop.freeze("May 7, 2016".to_datetime) do
        test_distribution(
          accounts: [:flat_value, :percentage],
          amount: 2_000,

          expect: {
            amounts: {
              flat_value: 400,
              percentage: 73
            },
            undistributed: 1527,
            history: [
              {
                amount: 400,
                explanation: "Distributed at priority level 7: $600.00 per month of $2,000.00 funds ($650.00 annual cap)"
              },
              {
                amount: 73,
                explanation: "Distributed at priority level 6: 30.00% per month of $1,600.00 funds ($200.00 annual cap)"
              },
              {
                amount: 1527,
                explanation: "Undistributed Funds"
              }
            ]
          }
        )
      end
    end

    it 'obeys the cap on accounts' do
      flat_value_account.update_attributes(
        cap: 1050,
        amount: 650
      )
      percentage_account.update_attributes(
        cap: 510,
        amount: 250
      )
      user.undistributed_funds = 150

      test_distribution(
        accounts: [:flat_value, :percentage],
        amount: 4_000,

        expect: {
          amounts: {
            flat_value: 1050,
            percentage: 510
          },
          undistributed: 3490,
          history: [
            {
              amount: 400,
              explanation: "Distributed at priority level 7: $600.00 per month of $4,000.00 funds ($1,050.00 cap)"
            },
            {
              amount: 260,
              explanation: "Distributed at priority level 6: 30.00% per month of $3,600.00 funds ($510.00 cap)"
            },
            {
              amount: 3340,
              explanation: "Undistributed Funds"
            }
          ]
        }
      )
    end

    it 'sends remaining funds beyond the cap into the overflow_into_account' do
      overflow_to_percent_account.update_attributes(
        amount: 200
      )
      overflow_to_flat_account.update_attributes(
        amount: 300
      )

      test_distribution(
        accounts: [:percentage, :flat_value, :overflow_to_percent, :overflow_to_flat],
        amount: 2_000,

        expect: {
          amounts: {
            percentage: 470,
            flat_value: 670,
            overflow_to_percent: 450,
            overflow_to_flat: 400
          },
          undistributed: 510,

          history: [
            { # flat value
              amount: 600,
              explanation: "Distributed at priority level 7: $600.00 per month of $2,000.00 funds"
            },
            { # percentage
              amount: 420,
              explanation: "Distributed at priority level 6: 30.00% per month of $1,400.00 funds"
            },
            { # overflow_to_percent
              amount: 250,
              explanation: "Distributed at priority level 4: $300.00 per month of $980.00 funds ($450.00 cap)"
            },
            { # percentage
              amount: 50,
              explanation: "Distributed at priority level 4: $50.00 (Overflowed from 'Overflow to Percent')"
            }, # $680 left
            { # 25% is 170
              # overflow_to_flat
              amount: 100,
              explanation: "Distributed at priority level 3: 25.00% per month of $680.00 funds ($400.00 cap)"
            }, # $580 left
            {
              # flat_value
              amount: 70,
              explanation: "Distributed at priority level 3: $70.00 (Overflowed from 'Overflow to Flat')"
            }, # $510 left
            {
              # undistributed
              amount: 510,
              explanation: "Undistributed Funds"
            }
          ]
        }
      )
    end

    it 'can handle a triple overflow' do
      double_overflow_account.update_attributes(
        amount: 550
      )
      flat_value_account.update_attributes(
        cap: 700
      )
      overflow_to_flat_account.update_attributes(
        amount: 55
      )

      test_distribution(
        accounts: [:flat_value, :overflow_to_flat, :double_overflow, :final],
        amount: 2_000,

        expect: {
          amounts: {
            flat_value: 700,
            overflow_to_flat: 400,
            double_overflow: 1000,
            final: 505
          },
          undistributed: 0,
          history: [
            { # flat_value
              amount: 600,
              explanation: "Distributed at priority level 7: $600.00 per month of $2,000.00 funds"
            },
            { # overflow_to_flat
              amount: 200, # hit monthly_cap
              explanation: "Distributed at priority level 3: 25.00% per month of $1,400.00 funds ($200.00 monthly cap)"
            },
            { # double_overflow
              # sending $1,200
              amount: 450, # hit cap
              explanation: "Distributed at priority level 2: $700.00 per month of $1,200.00 funds ($1,000.00 cap)"
            },
            { # overflow_to_flat
              # sending $250
              amount: 145,
              explanation: "Distributed at priority level 2: $250.00 (Overflowed from 'Double Overflow', $400.00 cap)"
            },
            { # flat_value
              # sending $105
              amount: 100,
              explanation: "Distributed at priority level 2: $105.00 (Overflowed from 'Overflow to Flat', $700.00 cap)"
            },
            {
              amount: 505,
              explanation: "Distributed at priority level 1: $8,000.00 per month of $505.00 funds"
              #explanation: "Distributed at priority level 1: $8,000.00 of $505.00"
            }
          ]
        }
      )
    end

    it 'when the account caps, it sends remaining funds to higher-priority accounts where this one was a prerequisite' do
      # lower-priority has prerequisite
      catchall_account.update_attributes(
        prerequisite_account: percentage_account,
        cap: 300
      )
      # higher-priority has prerequisite
      flat_value_account.update_attributes(
        prerequisite_account: percentage_account
      )
      percentage_account.update_attributes(
        cap: 150,
        amount: 50
      )

      test_distribution(
        accounts: [:catchall, :flat_value, :percentage],
        amount: 1_500,

        expect: {
          history: [
            { # percentage
              amount: 100,
              explanation: "Distributed at priority level 6: 30.00% per month of $1,500.00 funds ($150.00 cap)"
            },
            { # flat_value
              amount: 350,
              explanation: "Re-distributed from fulfilled prerequisite 'Percentage' at priority level 6 with $350.00 - Distributed at priority level 7: $600.00 per month of $350.00 funds"
            },
            { # catchall
              amount: 300,
              explanation: "Distributed at priority level 5: 100.00% per month of $1,050.00 funds ($300.00 cap)"
            },
            {
              amount: 750,
              explanation: "Undistributed Funds"
            }
          ],
          undistributed: 750,
          amounts: {
            flat_value: 350,
            percentage: 150,
            catchall: 300
          }
        }
      )
    end

    it 'when the account caps, it sends remaining funds to previously-skipped same-priority accounts where this one was a prerequisite' do
      # include same-priority with lower cap,
      # and same-priority with nil cap (which gets iterated after anyway)
      # and same-priority with higher cap

      # same-priority with lower cap, should redistribute
      catchall_account.update_attributes(
        prerequisite_account: percentage_account,
        priority: 5,
        cap: 450,
        amount: 10
      )
      # same priority with higher cap, doesn't redistribute since it's
      # on the way for the regular chain
      flat_value_account.update_attributes(
        prerequisite_account: percentage_account,
        priority: 5,
        cap: 700,
        amount: 250
      )
      # same priority with nil cap, doesn't redistribute
      final_account.update_attributes(
        prerequisite_account: percentage_account,
        priority: 5
      )

      percentage_account.update_attributes(
        cap: 475,
        amount: 50,
        add_per_month: 35,
        priority: 5
      )

      test_distribution(
        accounts: [:catchall, :flat_value, :final, :percentage],
        amount: 2_000,

        expect: {
          history: [
            { # percentage
              amount: 425,
              explanation: "Distributed at priority level 5: 35.00% per month of $2,000.00 funds ($475.00 cap)"
            },
            { # catchall
              amount: 275,
              explanation: "Re-distributed from fulfilled prerequisite 'Percentage' at priority level 5 with $275.00 - Distributed at priority level 5: 100.00% per month of $275.00 funds"
            },
            { # flat_value
              # send $1,100
              amount: 450,
              explanation: "Distributed at priority level 5: $600.00 per month of $2,000.00 funds ($700.00 cap)"
            },
            { # final
              amount: 850,
              explanation: "Distributed at priority level 5: $8,000.00 per month of $2,000.00 funds"
            }
          ],
          amounts: {
            catchall: 285,
            flat_value: 700,
            final: 850,
            percentage: 475
          },
          undistributed: 0
        }
      )
    end

    it 'on prerequisite-fulfilled higher-priority redistribution, an account that hits the cap will release the funds to be distributed along the normal chain' do
      # lower-priority has prerequisite
      catchall_account.update_attributes(
        prerequisite_account: percentage_account,
        cap: 3000
      )
      # higher-priority has prerequisite
      flat_value_account.update_attributes(
        prerequisite_account: percentage_account,
        cap: 500
      )
      percentage_account.update_attributes(
        cap: 150,
        amount: 50
      )

      test_distribution(
        accounts: [:catchall, :flat_value, :percentage],
        amount: 3_000,

        expect: {
          history: [
            { # percentage
              amount: 100,
              explanation: "Distributed at priority level 6: 30.00% per month of $3,000.00 funds ($150.00 cap)"
            },
            { # flat_value
              # sent $800
              amount: 500,
              explanation: "Re-distributed from fulfilled prerequisite 'Percentage' at priority level 6 with $800.00 - Distributed at priority level 7: $600.00 per month of $800.00 funds ($500.00 cap)"
            },
            { # catchall
              amount: 2400,
              explanation: "Distributed at priority level 5: 100.00% per month of $2,400.00 funds"
            }
          ],
          undistributed: 0,
          amounts: {
            flat_value: 500,
            percentage: 150,
            catchall: 2400
          }
        }
      )
    end

    it "doesn't send to prerequisite-fulfilled accounts if the monthly_cap was hit, but not the hard cap" do
      # lower-priority has prerequisite
      catchall_account.update_attributes(
        prerequisite_account: percentage_account,
        cap: 3000
      )
      # higher-priority has prerequisite
      flat_value_account.update_attributes(
        prerequisite_account: percentage_account,
        cap: 500
      )
      percentage_account.update_attributes(
        monthly_cap: 250,
        cap: 350,
        amount: 50
      )

      test_distribution(
        accounts: [:catchall, :flat_value, :percentage],
        amount: 2_000,

        expect: {
          history: [
            { # percentage
              amount: 250,
              explanation: "Distributed at priority level 6: 30.00% per month of $2,000.00 funds ($250.00 monthly cap)"
            },
            {
              amount: 1750,
              explanation: "Undistributed Funds"
            }
          ],
          undistributed: 1750,
          amounts: {
            flat_value: 0,
            percentage: 300,
            catchall: 0
          }
        }
      )
    end

    it "doesn't send to prerequisite-fulfilled accounts if the prerequisite was *already* fulfilled" do
      # higher-priority has prerequisite
      percentage_account.update_attributes(
        prerequisite_account: flat_value_account,
        add_per_month: 15,
        priority: 10,
        name: "Investments"
      )
      flat_value_account.update_attributes(
        add_per_month: 15,
        add_per_month_type: '%',
        cap: 8000,
        amount: 8000,
        priority: 10,
        name: "Emergency Fund"
      )

      test_distribution(
        accounts: [:flat_value, :percentage],
        amount: 5_500,

        expect: {
          history: [
            {
              amount: 825,
              explanation: "Distributed at priority level 10: 15.00% per month of $5,500.00 funds"
            },
            {
              amount: 4675,
              explanation: "Undistributed Funds"
            }
          ],
          undistributed: 4675,
          amounts: {
            flat_value: 8000,
            percentage: 825
          }
        }
      )
    end



    def test_distribution(options)
      options[:accounts].each do |account_name|
        public_send("#{account_name}_account").tap{|a| a.update_attribute(:user_id, user.id)}
      end

      income.amount = options[:amount]
      income.save!

      history_amounts = options[:expect][:history]
      hash_size = history_amounts.size
      histories = income.account_histories.order(id: :asc)
      histories.each do |history|
        history_hash = history_amounts.shift
        expect(
          [
            history.amount,
            history.explanation
          ]
        ).to eq(
          [
            history_hash[:amount].to_d,
            history_hash[:explanation]
          ]
        )
      end
      expect(
        history_size: histories.size
      ).to eq(
        history_size: hash_size
      )

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


    end
  end
end
