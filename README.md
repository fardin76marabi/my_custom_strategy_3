# my_custom_strategy_3
// when high or low of last highTF candel is break in lower tf candel in recent HTF candel we enter a trader in direction of that break

This EA implements a multi-timeframe breakout strategy that trades when price breaks the high/low of the previous H4 candle on the M1 timeframe. It enters long if price breaks above an H4 bullish candle's high, or short if breaking below an H4 bearish candle's low. The stop-loss is placed at the midpoint of the H4 candle's range, while take-profit uses a fixed 1.3 risk-reward ratio. Position sizing is calculated to risk 1% of account balance per trade. The system relies purely on price action without indicators, aiming to capture continuation moves after confirmed breakouts.
