# expert-advisors
This project contains a set of MetaTrader 4 (MT4) expert advisors (EAs), currently undergoing demo period.
The EAs take advantage of built-in Technical Indicators in MT4 to perform automated trades on EURUSD, EURGBP and GBPUSD Forex pairs.
Since automated trading performs trades following strict technical rules, it removes all emotional bias and, in theory, it will perform better than inexperienced traders.

In summary, the EAs in this project are:
* MACDTrigger: MACD based strategy that opens a trade when MACD indicator crosses the zero line, provided a set of conditions are met.
* MACDCross: MACD based strategy that captures price reversals by following the MACD indicator as it returns to zero.
* TripleEMA: Captures forming trends by detecting the alignment of three EMAs (Exponential Moving Average) indicators with 7, 48 and 84 periods.
* Reaper: Closes all trades to secure profits when profits are between 10% and 15% of the current balance.

The first EAs work on the hourly chart of three Forex pairs, EURUSD, EURGBP and GBPUSD, while the Reaper works on the minute chart of any Forex pair. The Reaper will not open any trade, it will just monitor the current profit and reap when a significant percentage of the balance is won.

The following sections describe each EA in detail.

## MACDTrigger

### Description

### Back testing

## MACDCross

### Description

### Back testing

## TripleEMA

### Description

### Back testing

## Reaper

### Description

### Back testing