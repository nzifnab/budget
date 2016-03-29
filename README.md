## Rules for income distribution

1. Income is distributed from highest priority (10) to lowest (1), followed by `cap` ascending (`nil`s last).

2. If `prerequisite_account` is set, and that account's `amount < cap`, then skip this account.

3. If `add_per_month` is a percentage, this indicates a % amount remaining at the start of that priority level, not a % of the total income value. This amount will be distributed into the account.

4. `add_per_month` distribution shall not exceed the `monthly_cap` on that account for the month. (only applies to the % version of `add_per_month`).

5. `add_per_month` distribution shall not exceed the `annual_cap` on that account for the calendar year (Jan 1 to Dec 31).

6. `add_per_month` distribution shall not exceed the `cap` on that account.

7. Overflow beyond an account's `cap` or `annual_cap` that would have otherwise satisfied the account's `monthly_cap` can be distributed into that account's `overflow_into`. If there is no `monthly_cap` on the account, then any amount beyond the `cap` that remains in `add_per_month` can be distributed into the `overflow_into`. These overflowed amounts *do* count towards monthly_cap and annual_cap values for the overflowed_into account.

8. The rules for an overflow_into's `cap`, `monthly_cap`, and `annual_cap` values apply. Any additional overflow for these `cap`s should then continue overflowing to the next `overflow_into` until either the total original `add_per_month` amount has been exhausted, or a `cap` is reached with no `overflow_into` specified.

9. If an account fulfills the `cap` in all overflows and still has some amount from `add_per_month` remaining, it will distribute the remaining amount into any accounts that had *this* one as a `prerequisite_account` with a priority >= this one's, in the same order as step (1), using the same distribution rules with the exception of rule 9b.

9b. The new distribution will look at "percentage" `add_per_month` accounts and distribute into them a % amount based on what that account *would* have received at it's priority level if it had not been originally skipped, during this distribution.

10. Any funds remaining after complete distribution has been completed will be placed in `User#undistributed_funds`

11. It skips all disabled accounts for distribution


NOTE: An alternate date can be selected for the 'Income'. `annual_cap` and `monthly_cap` rules use the specified date (or "Today" if not specified) when determining distribution.
