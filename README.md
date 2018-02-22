# expert-advisors
This project contains a set of MetaTrader 4 (MT4) expert advisors (EAs), currently undergoing demo period.
The EAs take advantage of built-in Technical Indicators in MT4 to perform automated trades on EURUSD and  GBPUSD Forex pairs.
Since automated trading performs trades following strict technical rules, it removes all emotional bias and, in theory, it will perform better than inexperienced traders.

In summary, the EAs in this project are:
* MACDTrigger: MACD based strategy that opens a trade when MACD indicator crosses the zero line, provided a set of conditions are met.
* MACDCross: MACD based strategy that captures price reversals by following the MACD indicator as it returns to zero.
* TripleEMA: Captures forming trends by detecting the alignment of three EMAs (Exponential Moving Average) indicators with 7, 48 and 84 periods.
* StochasticTrigger: A combination of 24-period SMA, price opening price, Parabolic SAR and Stochastic indicator to open trades.
* Reaper: Closes all trades to secure profits when profits are between 10% and 15% of the current balance.

The first four EAs work on the hourly chart of three Forex pairs, EURUSD and GBPUSD, while the Reaper works on the minute chart of any Forex pair. The Reaper will not open any trade, it will just monitor the current profit and reap when a significant percentage of the balance is won.

The following sections describe each EA in detail. For each EA (except the Reaper) a table with back testing results is given. Back-testing is done by MT4 Strategy Tester, on a demo account of a 5-point broker (1 PIP = 10 Points) and EUR as the base currency. 

## Risk Warning

The EAs in this project are provided without any guarantee that they will produce a profit, or at least break even. In fact, they can incur significant loss of capital, should you decide to apply them in a live trading account. They are designed to work on a platform that performs trades on the foreign exchange market on margin. This carries an extremely high level of risk and may not be suitable to all investors. Trading on FX with these EAs is definitely not suitable to anyone with limited resources or limited investment/trading experience or low risk tolerance.

Keep in mind that these EAs are work in progress and provided here for educational purposes only. They have never been tested with a live trading account; they have only been tested on a demo account and their results are debatable (quality of historical data, software bugs, limited back-testing period, etc.). In other words, if you're using these EAs to risk any amount of money, you're crazy.

## Back testing setup

Back testing is done using MT4 strategy tester, and the history data for EURUSD and GBPUSD available at http://www.histdata.com/. History data for 2017 were used. To import those data into MT4 History Center, please refer to http://www.histdata.com/f-a-q/metatrader-how-to-import-from-csv/

## MACDTrigger

### Description

This is a MACD based strategy, designed to open trades 5-10 times a month.

It opens a buy trade when MACD main line crosses zero from below and at the same time MACD signal line is below main with a minimum distance from zero equal to a threshold of 0.0005. It opens a sell trade when MACD main line crosses zero from above and MACD signal line is above main with a minimum distance from zero equal to a threshold of 0.0005.

It closes the trade either when MACD main crosses the zero line, or when a main/signal cross happens in a distance from zero larger than 0.001 and then MACD main crosses a line 1, 2, or 3 times the threshold of 0.001.

To clarify the closing condition, suppose that a long trade has opened when MACD main is zero and MACD signal is -0.0006. While the price moves up, both MACD main and MACD signal increase. At some point the price starts to reverse, and MACD signal moves above MACD main at 0.0025. This is a cross happening above the threshold of 0.001. While MACD main continues to drop, when it crosses the 0.002 line, the trade closes, hopefully at a profit.

### Parameters

* USER_TAKE_PROFIT_PIPS: Take profit value. Set to 2000 points, equivalent to 200 pips.
* USER_STOP_LOSS_PIPS: Stop loss value. Set to 2000 points, equivalent to 200 pips.
* USER_TRAIL_STOP_LOSS_PIPS: Set to 200 points equivalent to 20 pips. Every time the price moves 20 pips in your favor, stop loss moves 20 pips at the direction of the price.
* USER_MACD_OPENING_THRESHOLD: This is the minimum distance of MACD signal from zero, that allows opening a trade. Set to 0.0005 by default.
* USER_MACD_CLOSING_THRESHOLD: This is the threshold above which a cross of MACD main/signal must happen, to trigger a trade closing when MACD main crosses a line 1, 2 or 3 times the threshold.
* USER_POSITION: Set to 0.01 by default. That is a micro lot. Adjust to your liking.
* USER_LOGGER_DEBUG: Set to false by default. When set to true, it prints debug state info whenever a trade opens or closes.

### Back testing

Back Testing settings:
* Start: 1/1/2017
* End: 31/12/2017
* Position size: 0.01
* Spread: 20 Points (2 pips)

| EA | Currency Pair | SL | TSL | TP | EA specific settings | Profit | Absolute DD | Total Trades | Profit Trades (%) | Largest (Average) Profit | Largest (Average) Loss |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| MACDTrigger | GBPUSD | 2000 | 200 | 2000 | 0.001 / 0.0005 | -21.00 | 38.32 | 72 | 25 (34.72%) | 16.05 (5.19) | -11.00 (-3.21) |
| MACDTrigger | EURUSD | 2000 | 200 | 2000 | 0.001 / 0.0005 | 2.87 | 32.72 | 47 | 19 (40.43%) | 14.73 (4.25) | -18.48 (-2.78) |

*SL: Stop Loss, TSL: Trailing Stop Loss, TP: Take Profit, DD: Drawdown*

## MACDCross

### Description

This is a MACD based strategy to detect short term bearish and bullish reversals. It is designed to open trades 5-6 times a month.

It observes MACD main and signal crossings happening away from the zero line. When a cross is detected above a threshold, by default set to 0.001, then it waits for MACD main to cross a line 1,2,3 or 4 times the threshold to open a short trade. When a cross is detected below a threshold, set to -0.001, then it waits for MACD main to rise above a line 1,2,3 or 4 times the threshold to open a long trade.

To clarify opening conditions, consider this example. While price is moving up, both MACD main and signal rise above 0.001. At some point, price drops slightly, so MACD signal rises above main, and then as price continues to move up, main crosses again above signal. This is a cross happening above the threshold of 0.001. After this point, whenever MACD main will cross any of the lines 1,2,3 or 4 times the threshold from above, which means the price is dropping, then a short trade will open.

Trades close when MACD signal crosses the zero line.

### Parameters

* USER_TAKE_PROFIT_PIPS: Take profit value. Set to 2000 points, equivalent to 200 pips.
* USER_STOP_LOSS_PIPS: Stop loss value. Set to 2000 points, equivalent to 200 pips.
* USER_TRAIL_STOP_LOSS_PIPS: Set to 200 points equivalent to 20 pips. Every time the price moves 20 pips in your favor, stop loss moves 20 pips at the direction of the price.
* USER_MACD_THRESHOLD: This is the threshold above which a cross of MACD main/signal must happen, to trigger a trade opening when MACD main crosses a line 1, 2 or 3 times the threshold.
* USER_POSITION: Set to 0.01 by default. That is a micro lot. Adjust to your liking.
* USER_LOGGER_DEBUG: Set to false by default. When set to true, it prints debug state info whenever a trade opens or closes.

### Back testing

Back Testing settings:
* Start: 1/1/2017
* End: 31/12/2017
* Position size: 0.01
* Spread: 20 Points (2 pips)

| EA | Currency Pair | SL | TSL | TP | EA specific settings | Profit | Absolute DD | Total Trades | Profit Trades (%) | Largest (Average) Profit | Largest (Average) Loss |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| MACDCross | GBPUSD | 2000 | 200 | 2000 | 0.001 | 57.76 | 12.68 | 50 | 34 (68%)| 15.98 (3.24) | -10.77 (-3.27) |
| MACDCross | EURUSD | 2000 | 200 | 2000 | 0.001 | 50.97 | 3.83 | 35 | 25 (71.43%)| 9.53 (2.82) | -9.61 (-1.96) |

*SL: Stop Loss, TSL: Trailing Stop Loss, TP: Take Profit, DD: Drawdown*

## TripleEMA

### Description

This is a strategy based on 3 different EMAs combined with ADX. The long EMA is 84 periods, the medium EMA is 42 periods and the short EMA is 7 periods. ADX is set to 14 periods, its default value.

To go long, the short EMA must be above the medium EMA by a maximum threshold defined as the short_ema_threshold, the medium EMA must be above the slow EMA by a maximum threshold defined as  long_ema_threshold and ADX main must be above a threshold of 25.1 and ADX+ must be above ADX- for the last two periods. To go short, the opposite conditions apply, the shortEMA must be below medium EMA, medium EMA below long EMA and ADX- above ADX+ for the last two periods.

The long trades close when ADX- crosses above ADX+ and ADX main is above 25.1. The short trades close when ADX+ crosses above ADX- and ADX main is above 25.1.

It works on the hourly chart for EURUSD and GBPUSD. Optimization defines the two thresholds. For EURUSD the short threshold is 300 and the long 100. For GBPUSD, short threshold is 100 and the long threshold is 300.

### Parameters

* USER_TAKE_PROFIT_PIPS: Take profit value. Set to 2000 points, equivalent to 200 pips.
* USER_STOP_LOSS_PIPS: Stop loss value. Set to 1000 points, equivalent to 100 pips.
* USER_TRAIL_STOP_LOSS_PIPS: Set to 200 points equivalent to 20 pips. Every time the price moves 20 pips in your favor, stop loss moves 20 pips at the direction of the price.
* USER_LONG_EMA_THRESHOLD_PIPS: Maximum distance between long EMA and medium EMA that allows opening a trade. Set to 300 points (30 pips) for GBPUSD and 100 points (10 pips) for EURUSD.
* USER_SHORT_EMA_THRESHOLD_PIPS: Maximum distance between medium EMA and short EMA that allows opening a trade. Set to 100 points (10 pips) for GBPUSD and 300 points (30 pips) for EURUSD.
* USER_POSITION: Set to 0.01 by default. That is a micro lot. Adjust to your liking.
* USER_LOGGER_DEBUG: Set to false by default. When set to true, it prints debug state info whenever a trade opens or closes.

### Back testing

Back Testing settings:
* Start: 1/1/2017
* End: 31/12/2017
* Position size: 0.01
* Spread: 20 Points (2 pips)

| EA | Currency Pair | SL | TSL | TP | EA specific settings | Profit | Absolute DD | Total Trades | Profit Trades (%) | Largest (Average) Profit | Largest (Average) Loss |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TripleEMA | GBPUSD | 1000 | 200 | 2000 | 300/100 | 70.19 | 0.00 | 42 | 21 (50.00%)| 16.05 (5.73) | -8.30 (-2.39) |
| TripleEMA | EURUSD | 1000 | 200 | 2000 | 100/300 | 68.33 | 0.80 | 82 | 38 (46.34%) | 17.57 (4.33) | -6.29 (-2.19) |

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