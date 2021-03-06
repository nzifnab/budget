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
        amount: 55,
        monthly_cap: nil,
        add_per_month: 15
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
              amount: 210,
              explanation: "Distributed at priority level 3: 15.00% per month of $1,400.00 funds"
            },
            { # double_overflow
              # sending $1,190
              amount: 450, # hit cap
              explanation: "Distributed at priority level 2: $700.00 per month of $1,190.00 funds ($1,000.00 cap)"
            },
            { # overflow_to_flat
              # sending $250
              amount: 135,
              explanation: "Distributed at priority level 2: $250.00 (Overflowed from 'Double Overflow', $400.00 cap)"
            },
            { # flat_value
              # sending $115
              amount: 100,
              explanation: "Distributed at priority level 2: $115.00 (Overflowed from 'Overflow to Flat', $700.00 cap)"
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

    it 'respects monthly and annual caps when distributing into overflow accounts' do
      percentage_account.update_attributes(
        add_per_month: 0,
        monthly_cap: 450
      )
      overflow_to_percent_account.update_attributes(
        add_per_month: 2,
        add_per_month_type: "%",
        annual_cap: 1_000,
        cap: 750
      )
      double_overflow_account.update_attributes(
        cap: 495,
        add_per_month: 35,
        add_per_month_type: "%",
        overflow_into_account: overflow_to_percent_account
      )

      percentage_account.account_histories.create!(
        created_at: "February 9, 2016".to_datetime,
        amount: 75,
        income_id: 446
      )
      overflow_to_percent_account.account_histories.create!(
        created_at: "January 3, 2016".to_datetime,
        amount: 300,
        income_id: 444
      )
      overflow_to_percent_account.account_histories.create!(
        created_at: "February 8, 2016".to_datetime,
        amount: 450,
        income_id: 445
      )

      # Don't count non-income ones...
      overflow_to_percent_account.account_histories.create!(
        created_at: "February 15, 2016".to_datetime,
        amount: 350,
        quick_fund_id: 8
      )
      double_overflow_account.account_histories.create!(
        created_at: "February 15, 2016".to_datetime,
        amount: 80,
        quick_fund_id: 8
      )

      Timecop.freeze("February 17, 2016".to_datetime) do
        test_distribution(
          accounts: [:overflow_to_percent, :percentage, :double_overflow],
          amount: 5_000,

          expect: {
            history: [
              { # overflow_to_percent
                amount: 100,
                explanation: "Distributed at priority level 4: 2.00% per month of $5,000.00 funds"
              },
              { # double_overflow ($1715 is 35% of 4500)
                amount: 495,
                explanation: "Distributed at priority level 2: 35.00% per month of $4,900.00 funds ($495.00 cap)"
              },
              { # overflow_to_percent ($1,220 sent here)
                amount: 150,
                explanation: "Distributed at priority level 2: $1,220.00 (Overflowed from 'Double Overflow', $1,000.00 annual cap)"
              },
              { # percentage ($1070 sent here)
                amount: 375,
                explanation: "Distributed at priority level 2: $1,070.00 (Overflowed from 'Overflow to Percent', $450.00 monthly cap)"
              },
              {
                amount: 3880,
                explanation: "Undistributed Funds"
              }
            ],
            undistributed: 3880,
            amounts: {
              overflow_to_percent: 250,
              percentage: 375,
              double_overflow: 495
            }
          }
        )
      end
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
              explanation: "Re-distributed from fulfilled prerequisite 'Percentage' at priority level 5 with $275.00 - Distributed at priority level 5: 100.00% per month of $2,000.00 funds"
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

    it 'sends to prerequisite-fulfilled accounts with a percentage monthly amount with a value up to the amount that would have been distributed if that account had not been skipped' do
      # For instance, if an account is set to 15% at priority level 10, and
      # the amount that it *would* have received at that point is $200, it will
      # use all available redistribution funds to fulfill that $200,
      # and no more. It will at this point ignore the 15%,
      # since it already knows what 15% should have been.
      # If the prerequisite used $50 and then capped, the redistributed
      # 15%-account will get $200.

      percentage_account.update_attributes(
        name: "Emergency Fund",
        add_per_month: 15,
        add_per_month_type: "%",
        cap: 11_000,
        amount: 9_450,
        priority: 9,
        prerequisite_account: catchall_account
      )
      flat_value_account.update_attributes(
        name: "Investments",
        add_per_month: 15,
        add_per_month_type: "%",
        priority: 8,
        prerequisite_account: percentage_account
      )
      catchall_account.update_attributes(
        name: "Credit Card",
        add_per_month: 20,
        add_per_month_type: "%",
        priority: 7,
        cap: 0,
        amount: -100
      )

      test_distribution(
        accounts: [:percentage, :flat_value, :catchall],
        amount: 5_000,

        expect: {
          history: [
            { # catchall
              amount: 100,
              explanation: "Distributed at priority level 7: 20.00% per month of $5,000.00 funds ($0.00 cap)"
            },
            { # percentage
              amount: 750,
              explanation: "Re-distributed from fulfilled prerequisite 'Credit Card' at priority level 7 with $900.00 - Distributed at priority level 9: 15.00% per month of $5,000.00 funds"
            },
            #{ # flat_value
            #  amount: 150,
            #  explanation: "Re-distributed from fulfilled prerequisite 'Emergency Fund' at priority level 9 with $150.00 - Distributed at priority level 8: 15.00% per month of $5,000.00 funds"
            #},
            { # undistributed
              amount: 4_150,
              explanation: "Undistributed Funds"
            }
          ],

          undistributed: 4150,
          amounts: {
            percentage: 10_200,
            flat_value: 0,
            catchall: 0
          }
        }
      )
    end

    it 'sends to prerequisite-fulfilled accounts that fulfill further prerequisites' do
      # For instance, if an account is set to 15% at priority level 10, and
      # the amount that it *would* have received at that point is $200, it will
      # use all available redistribution funds to fulfill that $200,
      # and no more. It will at this point ignore the 15%,
      # since it already knows what 15% should have been.
      # If the prerequisite used $50 and then capped, the redistributed
      # 15%-account will get $200.

      percentage_account.update_attributes(
        name: "Emergency Fund",
        add_per_month: 15,
        add_per_month_type: "%",
        cap: 9_500,
        amount: 9_450,
        priority: 9,
        prerequisite_account: catchall_account
      )
      flat_value_account.update_attributes(
        name: "Investments",
        add_per_month: 15,
        add_per_month_type: "%",
        priority: 8,
        prerequisite_account: percentage_account
      )
      catchall_account.update_attributes(
        name: "Credit Card",
        add_per_month: 20,
        add_per_month_type: "%",
        priority: 7,
        cap: 0,
        amount: -100
      )

      test_distribution(
        accounts: [:percentage, :flat_value, :catchall],
        amount: 5_000,

        expect: {
          history: [
            { # catchall
              amount: 100,
              explanation: "Distributed at priority level 7: 20.00% per month of $5,000.00 funds ($0.00 cap)"
            },
            { # percentage
              amount: 50,
              explanation: "Re-distributed from fulfilled prerequisite 'Credit Card' at priority level 7 with $900.00 - Distributed at priority level 9: 15.00% per month of $5,000.00 funds ($9,500.00 cap)"
            },
            { # flat_value
              amount: 700,
              explanation: "Re-distributed from fulfilled prerequisite 'Emergency Fund' at priority level 9 with $700.00 - Distributed at priority level 8: 15.00% per month of $5,000.00 funds"
            },
            { # undistributed
              amount: 4_150,
              explanation: "Undistributed Funds"
            }
          ],

          undistributed: 4150,
          amounts: {
            percentage: 9_500,
            flat_value: 700,
            catchall: 0
          }
        }
      )
    end

    it 'sends remaining funds beyond the cap into the overflow_into_account, even if the account is capped' do
      overflow_to_percent_account.update_attributes(
        cap: 0,
        amount: 0,
        add_per_month: 100,
        add_per_month_type: "%",
        priority: 1,
        name: "Remaining Funds - Redirect to Invest"
      )
      percentage_account.update_attributes(
        add_per_month: 0,
        add_per_month_type: "$",
        name: "Investments"
      )

      test_distribution(
        accounts: [:flat_value, :percentage, :overflow_to_percent],
        amount: 2_000,

        expect: {
          amounts: {
            flat_value: 600,
            overflow_to_percent: 0,
            percentage: 1400
          },
          undistributed: 0,

          history: [
            { # flat value
              amount: 600,
              explanation: "Distributed at priority level 7: $600.00 per month of $2,000.00 funds"
            },
            { # percentage (redirected from overflow_to_percent)
              amount: 1400,
              explanation: "Distributed at priority level 1: $1,400.00 (Overflowed from 'Remaining Funds - Redirect to Invest')"
            }
          ]
        }
      )
    end

    it 'sends remaining funds beyond the cap into the overflow_into_account, even if the account is even when both accounts are at the same priority level' do
      percentage_account.update_attributes(
        name: "IRA Account",
        cap: nil,
        add_per_month: 10,
        add_per_month_type: "%",
        priority: 10
      )
      overflow_to_percent_account.update_attributes(
        cap: 1000,
        amount: 1000,
        add_per_month: 20,
        add_per_month_type: "%",
        priority: 10,
        name: "Emergency Fund"
      )

      test_distribution(
        accounts: [:percentage, :overflow_to_percent],
        amount: 1_000,

        expect: {
          amounts: {
            percentage: 300,
            overflow_to_percent: 1000
          },
          undistributed: 700,

          history: [
            { # IRA, overflowed from emergency
              amount: 200,
              explanation: "Distributed at priority level 10: $200.00 (Overflowed from 'Emergency Fund')"
            },
            {
              amount: 100,
              explanation: "Distributed at priority level 10: 10.00% per month of $1,000.00 funds"
            },
            {
              amount: 700,
              explanation: "Undistributed Funds"
            }
          ]
        }
      )
    end

    it 'sends remaining funds beyond monthly_cap into overflow_into_account if the per_month type is %' do
      flat_value_account.update_attributes(
        name: "Investments",
        add_per_month: 0,
        add_per_month_type: "$",
        enabled: true,
        priority: 10
      )
      overflow_to_flat_account.update_attributes(
        name: "Vanguard IRA",
        add_per_month: 7.5,
        add_per_month_type: "%",
        monthly_cap: 100,
        annual_cap: 5500,
        cap: nil,
        priority: 10,
        enabled: true,
        overflow_into_account: flat_value_account
      )
      overflow_to_percent_account.update_attributes(
        name: "Emergency Fund",
        add_per_month: 7.5,
        add_per_month_type: "%",
        cap: 200,
        overflow_into_account: overflow_to_flat_account,
        priority: 10,
        enabled: true
      )

      test_distribution(
        accounts: [:flat_value, :overflow_to_flat, :overflow_to_percent],
        amount: 1_650,

        expect: {
          amounts: {
            flat_value: 23.75,
            overflow_to_flat: 100,
            overflow_to_percent: 123.75
          },
          undistributed: 1_402.5,

          history: [
            { # Emergency Fund
              amount: 123.75,
              explanation: "Distributed at priority level 10: 7.50% per month of $1,650.00 funds"
            },
            { # Vanguard IRA
              amount: 100,
              explanation: "Distributed at priority level 10: 7.50% per month of $1,650.00 funds ($100.00 monthly cap)"
            },
            { # Investments
              amount: 23.75,
              explanation: "Distributed at priority level 10: $23.75 (Overflowed from 'Vanguard IRA')"
            },
            { # undistributed
              amount: 1_402.5,
              explanation: "Undistributed Funds"
            }
          ]
        }
      )
    end

    it "respects the correct monthly and annual caps when a different applied_at is specified" do
      percentage_account.update_attributes(
        monthly_cap: 200,
        amount: 50
      )
      flat_value_account.update_attributes(
        annual_cap: 1500,
        amount: 500,
        add_per_month: 800
      )
      Timecop.freeze("August 10, 2015".to_datetime) do
        percentage_account.account_histories.create!(
          income_id: 995,
          amount: 50
        )
        flat_value_account.account_histories.create!(
          income_id: 995,
          amount: 300
        )
      end

      Timecop.freeze("September 25, 2015".to_datetime) do
        percentage_account.account_histories.create!(
          income_id: 996,
          amount: 60
        )
        flat_value_account.account_histories.create!(
          income_id: 996,
          amount: 350
        )
      end

      Timecop.freeze("October 25, 2015".to_datetime) do
        percentage_account.account_histories.create!(
          income_id: 997,
          amount: 75
        )
        flat_value_account.account_histories.create!(
          income_id: 997,
          amount: 550
        )
      end

      Timecop.freeze("February 14, 2016".to_datetime) do
        percentage_account.account_histories.create!(
          income_id: 998,
          amount: 100
        )
        flat_value_account.account_histories.create!(
          income_id: 998,
          amount: 300
        )
      end

      Timecop.freeze("March 2, 2016".to_datetime) do
        percentage_account.account_histories.create!(
          income_id: 999,
          amount: 150
        )
        flat_value_account.account_histories.create!(
          income_id: 999,
          amount: 600
        )
      end

      Timecop.freeze("March 15, 2016".to_datetime) do
        test_distribution(
          accounts: [:percentage, :flat_value],
          amount: 1_500,
          applied_at: "September 24, 2015".to_datetime,

          expect: {
            history: [
              {
                amount: 300,
                explanation: "Distributed at priority level 7: $800.00 per month of $1,500.00 funds ($1,500.00 annual cap)"
              },
              {
                amount: 140,
                explanation: "Distributed at priority level 6: 30.00% per month of $1,200.00 funds ($200.00 monthly cap)"
              },
              {
                amount: 1060,
                explanation: "Undistributed Funds"
              }
            ],
            amounts: {
              flat_value: 800,
              percentage: 190
            },
            undistributed: 1060
          }
        )
      end
    end


    def test_distribution(options)
      options[:accounts].each do |account_name|
        public_send("#{account_name}_account").tap{|a| a.update_attribute(:user_id, user.id)}
      end

      income.amount = options[:amount]
      income.applied_at = options[:applied_at].presence
      income.save!

      history_amounts = options[:expect][:history]
      hash_size = history_amounts.size
      histories = income.account_histories.order(id: :asc)

      histories.each do |history|
        history_hash = history_amounts.shift

        if history_hash
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
        else
          raise "Unexpected history: #{history.inspect}"
        end
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

  describe "#destroy" do
    let(:user){User.create!(
      first_name: "User",
      last_name: "Dude",
      undistributed_funds: 650,
      password: "password",
      email: "example@example.com"
    )}
    let(:account1){Account.create!(
      name: "Account 1",
      priority: 10,
      enabled: true,
      amount: 350
    )}
    let(:account2){Account.create!(
      name: "Account 2",
      priority: 5,
      enabled: true,
      amount: 600
    )}
    let(:account3){Account.create!(
      name: "Account 3",
      priority: 3,
      enabled: false,
      amount: 1050
    )}

    it "reverts account amounts based on the histories in the income" do
      income = Income.create!(
        amount: 50,
        skip_distribution: true,
        user: user,
        account_histories: [
          AccountHistory.new(
            account: account1,
            amount: 350
          ), AccountHistory.new(
            account: account2,
            amount: 150
          ), AccountHistory.new(
            account: account3,
            amount: 200
          ), AccountHistory.new(
            amount: 450
          )
        ]
      )
      expect(user.reload.undistributed_funds).to eq(1100)

      expect(income.destroy).to be_truthy
      expect(account1.reload.amount).to eq(0)
      expect(account2.reload.amount).to eq(450)
      expect(account3.reload.amount).to eq(850)
      expect(user.reload.undistributed_funds).to eq(650)
    end

    it "gives a validation error if the account has insufficient funds to revert" do
      income = Income.create!(
        amount: 50,
        skip_distribution: true,
        user: user,
        account_histories: [
          AccountHistory.new(
            account: account2,
            amount: 150
          ),
          AccountHistory.new(
            account: account1,
            amount: 351
          )
        ]
      )

      expect(income.destroy).to be_falsey
      expect(account1.reload.amount).to eq(350)
      expect(account2.reload.amount).to eq(600)
      expect(income.errors.messages[:amount].first).to eq(
        "Account 1 - Insufficient Funds"
      )
    end
  end
end
