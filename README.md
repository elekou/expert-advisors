# expert-advisors
This project contains a set of MetaTrader 4 (MT4) expert advisors (EAs), currently undergoing demo period.
The EAs take advantage of built-in Technical Indicators in MT4 to perform automated trades on EURUSD, EURGBP and GBPUSD Forex pairs.
Since automated trading performs trades following strict technical rules, it removes all emotional bias and, in theory, it will perform better than inexperienced traders.

In summary, the EAs in this project are:
* MACDTrigger: MACD based strategy that opens a trade when MACD indicator crosses the zero line, provided a set of conditions are met.
* MACDCross: MACD based strategy that captures price reversals by following the MACD indicator as it returns to zero.
* TripleEMA: Captures forming trends by detecting the alignment of three EMAs (Exponential Moving Average) indicators with 7, 48 and 84 periods.
* StochasticTrigger: A combination of 24-period SMA, price opening price, Parabolic SAR and Stochastic indicator to open trades.
* Reaper: Closes all trades to secure profits when profits are between 10% and 15% of the current balance.

The first four EAs work on the hourly chart of three Forex pairs, EURUSD, EURGBP and GBPUSD, while the Reaper works on the minute chart of any Forex pair. The Reaper will not open any trade, it will just monitor the current profit and reap when a significant percentage of the balance is won.

The following sections describe each EA in detail. For each EA (except the Reaper) a table with back testing results is given. Back-testing is done by MT4 Strategy Tester, on a demo account of a 5-point broker (1 PIP = 10 Points) and EUR as the base currency. 

## Risk Warning

The EAs in this project are provided without any guarantee that they will produce a profit, or at least break even. In fact, they can incur significant loss of capital, should you decide to apply them in a live trading account. They are designed to work on a platform that performs trades on the foreign exchange market on margin. This carries an extremely high level of risk and may not be suitable to all investors. Trading on FX with these EAs is definitely not suitable to anyone with limited resources or limited investment/trading experience or low risk tolerance.

Keep in mind that these EAs are work in progress and provided here for educational purposes only. They have never been tested with a live trading account; they have only been tested on a demo account and their results are debatable (quality of historical data, software bugs, limited back-testing period, etc.). In other words, if you're using these EAs to risk any amount of money, you're crazy.

## Back testing setup

Back testing is done using MT4 strategy tester, and the history data for EURGBP, EURUSD and GBPUSD available at http://www.histdata.com/. History data for 2017 were used. To import those data into MT4 History Center, please refer to http://www.histdata.com/f-a-q/metatrader-how-to-import-from-csv/

## MACDTrigger

### Description

### Parameters

### Back testing

Back Testing settings:
* Start: 1/1/2017
* End: 31/12/2017
* Position size: 0.01
* Spread: 20 Points (2 pips)

| EA | Currency Pair | SL | TSL | TP | EA specific settings | Profit | Absolute DD | Total Trades | Profit Trades (%) | Largest (Average) Profit | Largest (Average) Loss |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| | | | | | | | | | | | |

*SL: Stop Loss, TSL: Trailing Stop Loss, TP: Take Profit, DD: Drawdown*

## MACDCross

### Description

### Parameters

### Back testing

Back Testing settings:
* Start: 1/1/2017
* End: 31/12/2017
* Position size: 0.01
* Spread: 20 Points (2 pips)

| EA | Currency Pair | SL | TSL | TP | EA specific settings | Profit | Absolute DD | Total Trades | Profit Trades (%) | Largest (Average) Profit | Largest (Average) Loss |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| | | | | | | | | | | | |

*SL: Stop Loss, TSL: Trailing Stop Loss, TP: Take Profit, DD: Drawdown*

## TripleEMA

### Description

### Parameters

### Back testing

Back Testing settings:
* Start: 1/1/2017
* End: 31/12/2017
* Position size: 0.01
* Spread: 20 Points (2 pips)

| EA | Currency Pair | SL | TSL | TP | EA specific settings | Profit | Absolute DD | Total Trades | Profit Trades (%) | Largest (Average) Profit | Largest (Average) Loss |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| | | | | | | | | | | | |

*SL: Stop Loss, TSL: Trailing Stop Loss, TP: Take Profit, DD: Drawdown*

## StochasticTrigger

### Description

### Parameters

### Back testing

Back Testing settings:
* Start: 1/1/2017
* End: 31/12/2017
* Position size: 0.01
* Spread: 20 Points (2 pips)

| EA | Currency Pair | SL | TSL | TP | EA specific settings | Profit | Absolute DD | Total Trades | Profit Trades (%) | Largest (Average) Profit | Largest (Average) Loss |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| | | | | | | | | | | | |

*SL: Stop Loss, TSL: Trailing Stop Loss, TP: Take Profit, DD: Drawdown*

## Reaper

### Description

### Parameters