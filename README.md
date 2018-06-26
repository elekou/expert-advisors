# expert-advisors
This project contains a set of MetaTrader 4 (MT4) expert advisors (EAs), currently undergoing demo period.
The EAs take advantage of built-in Technical Indicators in MT4 to perform automated trades on EURUSD and  GBPUSD Forex pairs.
Since automated trading performs trades following strict technical rules, it removes all emotional bias and, in theory, it will perform better than inexperienced traders.

In summary, the EAs in this project are:
* MATrigger: Compares the values of SMA24 to SMA48 and goes long or short at a a cross.
* Reaper: Closes all trades to secure profits when profits are between 10% and 15% of the current balance.

The first EA works on the hourly chart of three Forex pairs, EURUSD, EURSEK and GBPUSD, while the Reaper works on the minute chart of any Forex pair. The Reaper will not open any trade, it will just monitor the current profit and reap when a significant percentage of the balance is won.

## Risk Warning

The EAs in this project are provided without any guarantee that they will produce a profit, or at least break even. In fact, they can incur significant loss of capital, should you decide to apply them in a live trading account. They are designed to work on a platform that performs trades on the foreign exchange market on margin. This carries an extremely high level of risk and may not be suitable to all investors. Trading on FX with these EAs is definitely not suitable to anyone with limited resources or limited investment/trading experience or low risk tolerance.

Keep in mind that these EAs are work in progress and provided here for educational purposes only. They have never been tested with a live trading account; they have only been tested on a demo account and their results are debatable (quality of historical data, software bugs, limited back-testing period, etc.). In other words, if you're using these EAs to risk any amount of money, you're crazy.