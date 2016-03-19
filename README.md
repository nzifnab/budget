## Rules for income distribution

1. Income is distributed from highest priority (10) to lowest (1), followed by `cap` ascending (`nil`s last).

~~2. If `prerequisite_account` is set, then that account's `amount` must `==` it's `cap` before this account can have any distribution performed (skip this account)~~

2. If `prerequisite_account` is set, and that account's `amount < cap`, then skip this account.

3. If `add_per_month` is a percentage, this indicates a % amount remaining at the start of that priority level, not a % of the total income value. This amount will be distributed into the account.

4. `add_per_month` distribution shall not exceed the `monthly_cap` on that account for the month. (only applies to the % version of `add_per_month`).

5. `add_per_month` distribution shall not exceed the `annual_cap` on that account for the year.

6. `add_per_month` distribution shall not exceed the `cap` on that account.

7. Overflow beyond an account's `cap` that would have otherwise satisfied the account's `monthly_cap` can be distributed into that account's `overflow_into`. If there is no `monthly_cap` on the account, then any amount beyond the `cap` that remains in `add_per_month` can be distributed into the `overflow_into`.

8. The rules for an overflow_into's `cap` apply, but the `monthly_cap` does not. Any additional overflow for this `cap` should then continue overflowing to the next `overflow_into` until either the total original `add_per_month` amount has been exhausted, or a `cap` is reached with no `overflow_into` specified.

98. If an account fulfills the `cap` in all overflows and still has some amount from `add_per_month` remaining, it will distribute the remaining amount into any accounts that had *this* one as a `prerequisite_account` with a priority <= this one's, in the same order as step (1), using the same distribution rules.

10. Any funds remaining after complete distribution has been completed will be placed in `User#undistributed_funds`
