//+------------------------------------------------------------------+
//|                                          CandlestickPatterns.mq4 |
//|                                              lefterisk@gmail.com |
//|                        http://www.myfxbook.com/members/lefterisk |
//+------------------------------------------------------------------+
//| Trades a variety of candlestick patterns. For a description of   |
//| patterns being traded, check the online course at babypips.com:  |
//| www.babypips.com/learn/forex/elementary#japanese-candle-sticks   |
//|                                                                  |
//| The patterns this EA trades are (magic numbers in parenthesis):  |
//| o Bullish (1000) and Bearish (1001) Engulfing                    |
//| o Three White Soldiers (1002) and Three Black Crows (1003)       |
//| o Morning (1004) and Evening (1005) Star                         |
//| o Three Inside Up (1006) and Down (1007)                         |
//|                                                                  |
//| The rules applied by this EA are:                                |
//| o Whenever a pattern is detected, a trade opens in the direction |
//|   the pattern dictates, unless a trade is already open in that   |
//|   direction for this pattern.                                    |
//| o All trades that were opened by a bullish pattern, will close   |
//|   when any bearish pattern is detected                           |
//| o All trades that were opened by a bearish pattern, will close   |
//|   when any bullish pattern is detected                           |
//| o Stop loss is calculated for each pattern, the general rule is  |
//|   that the SL is set away from the first candlestick at the      |
//|   pattern's height, but there are variations. Check the code.    |
//| o Take Profit is set for all trades by the extern variable       |
//|   USER_TAKE_PROFIT_PIPS                                          |
//|                                                                  |
//+------------------------------------------------------------------+
#include <stderror.mqh>
#include <stdlib.mqh>
#property copyright "lefterisk@gmail.com"
#property link      "http://www.myfxbook.com/members/lefterisk"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| USER_ defined global variables                                   |
//+------------------------------------------------------------------+
double USER_TAKE_PROFIT=0.0;
double USER_STOP_LOSS=0.0;
double USER_TRAIL_STOP_LOSS=0.0;
int USER_MAGIC_BULLISH_ENGULFING=1000;
int USER_MAGIC_BEARISH_ENGULFING=1001;
int USER_MAGIC_THREE_WHITE_SOLDIERS=1002;
int USER_MAGIC_THREE_BLACK_CROWS=1003;
int USER_MAGIC_MORNING_STAR=1004;
int USER_MAGIC_EVENING_STAR=1005;
int USER_MAGIC_THREE_INSIDE_UP=1006;
int USER_MAGIC_THREE_INSIDE_DOWN=1007;
extern int USER_TAKE_PROFIT_PIPS=2000;                               // Take Profit in pips
extern int USER_STOP_LOSS_PIPS=200;                                  // Stop Loss in pips
extern int USER_TRAIL_STOP_LOSS_PIPS=200;                            // Trail Stop Loss distance in pips
extern double USER_POSITION=0.01;                                    // Base of position size calculations
extern bool USER_LOGGER_DEBUG=false;                                 // Enable or disable debug log
extern int USER_BACK_PERIODS=24;                                     // How many hours back to check price for support/resistance

//+------------------------------------------------------------------+
//| Indicator variables, re-calculated on every new bar.             |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   USER_TAKE_PROFIT = USER_TAKE_PROFIT_PIPS * Point;
   USER_STOP_LOSS = USER_STOP_LOSS_PIPS * Point;
   USER_TRAIL_STOP_LOSS = USER_TRAIL_STOP_LOSS_PIPS * Point;
   
   Alert("Init Symbol=", Symbol(), ", TP=", USER_TAKE_PROFIT,
      ", SL=", USER_STOP_LOSS, ", TrailSL=", USER_TRAIL_STOP_LOSS);
   
   return(INIT_SUCCEEDED);
}
 
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // No deinit action required
}
 
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // This EA only considers trading when a new bar opens
   if (!NewBar())
      return;
   
   Log();

   //+---------------------------------------------------------------+
   //| Bullish Engulfing                                             |
   //+---------------------------------------------------------------+
   if (
     OpenBullishEngulfing() &&
     !LongIsOpen(USER_MAGIC_BULLISH_ENGULFING)
   ){
      OpenLong(
         CalculatePositionSize(USER_MAGIC_BULLISH_ENGULFING),
         USER_MAGIC_BULLISH_ENGULFING,
         CalculateSL(USER_MAGIC_BULLISH_ENGULFING),
         USER_TAKE_PROFIT);
   }

   if (
      LongIsOpen(USER_MAGIC_BULLISH_ENGULFING) &&
      AllBearishPatterns()
   ){
      int ticket = FindLong(USER_MAGIC_BULLISH_ENGULFING);
      CloseLong(ticket, CalculatePositionSize(USER_MAGIC_BULLISH_ENGULFING));
   }
   
   //+---------------------------------------------------------------+
   //| Bearish Engulfing                                             |
   //+---------------------------------------------------------------+
   if (
     OpenBearishEngulfing() &&
     !ShortIsOpen(USER_MAGIC_BEARISH_ENGULFING)
   ){
      OpenShort(
         CalculatePositionSize(USER_MAGIC_BEARISH_ENGULFING),
         USER_MAGIC_BEARISH_ENGULFING,
         CalculateSL(USER_MAGIC_BEARISH_ENGULFING),
         USER_TAKE_PROFIT);
   }
 
   if (
      ShortIsOpen(USER_MAGIC_BEARISH_ENGULFING) &&
      AllBullishPatterns()
   ){
      int ticket = FindShort(USER_MAGIC_BEARISH_ENGULFING);
      CloseShort(ticket, CalculatePositionSize(USER_MAGIC_BEARISH_ENGULFING));
   }
   
   //+---------------------------------------------------------------+
   //| Three White Soldiers                                          |
   //+---------------------------------------------------------------+
   if (
      OpenThreeWhiteSoldiers() &&
      !LongIsOpen(USER_MAGIC_THREE_WHITE_SOLDIERS)
   ){
      OpenLong(
         CalculatePositionSize(USER_MAGIC_THREE_WHITE_SOLDIERS),
         USER_MAGIC_THREE_WHITE_SOLDIERS,
         CalculateSL(USER_MAGIC_THREE_WHITE_SOLDIERS),
         USER_TAKE_PROFIT);
   }

   if (
      LongIsOpen(USER_MAGIC_THREE_WHITE_SOLDIERS) &&
      AllBearishPatterns()
   ){
      int ticket = FindLong(USER_MAGIC_THREE_WHITE_SOLDIERS);
      CloseLong(ticket, CalculatePositionSize(USER_MAGIC_THREE_WHITE_SOLDIERS));
   }
   
   //+---------------------------------------------------------------+
   //| Three Black Crows                                             |
   //+---------------------------------------------------------------+
   if (
      OpenThreeBlackCrows() &&
      !ShortIsOpen(USER_MAGIC_THREE_BLACK_CROWS)
   ){
      OpenShort(
         CalculatePositionSize(USER_MAGIC_THREE_BLACK_CROWS),
         USER_MAGIC_THREE_BLACK_CROWS,
         CalculateSL(USER_MAGIC_THREE_BLACK_CROWS),
         USER_TAKE_PROFIT);
   }
 
   if (
      ShortIsOpen(USER_MAGIC_THREE_BLACK_CROWS) &&
      AllBullishPatterns()
   ){
      int ticket = FindShort(USER_MAGIC_THREE_BLACK_CROWS);
      CloseShort(ticket, CalculatePositionSize(USER_MAGIC_THREE_BLACK_CROWS));
   }   
   
   //+---------------------------------------------------------------+
   //| Morning Star                                                  |
   //+---------------------------------------------------------------+
   if (
      OpenMorningStar() &&
      !LongIsOpen(USER_MAGIC_MORNING_STAR)
   ){
      OpenLong(
         CalculatePositionSize(USER_MAGIC_MORNING_STAR),
         USER_MAGIC_MORNING_STAR,
         CalculateSL(USER_MAGIC_MORNING_STAR),
         USER_TAKE_PROFIT);
   }

   if (
      LongIsOpen(USER_MAGIC_MORNING_STAR) &&
      AllBearishPatterns()
   ){
      int ticket = FindLong(USER_MAGIC_MORNING_STAR);
      CloseLong(ticket, CalculatePositionSize(USER_MAGIC_MORNING_STAR));
   }
   
   //+---------------------------------------------------------------+
   //| Evening Star                                                  |
   //+---------------------------------------------------------------+
   if (
      OpenEveningStar() &&
      !ShortIsOpen(USER_MAGIC_EVENING_STAR)
   ){
      OpenShort(
         CalculatePositionSize(USER_MAGIC_EVENING_STAR),
         USER_MAGIC_EVENING_STAR,
         CalculateSL(USER_MAGIC_EVENING_STAR),
         USER_TAKE_PROFIT);
   }
 
   if (
      ShortIsOpen(USER_MAGIC_EVENING_STAR) &&
      AllBullishPatterns()
   ){
      int ticket = FindShort(USER_MAGIC_EVENING_STAR);
      CloseShort(ticket, CalculatePositionSize(USER_MAGIC_EVENING_STAR));
   }  
   
   //+---------------------------------------------------------------+
   //| Three Inside Up                                               |
   //+---------------------------------------------------------------+
   if (
      OpenThreeInsideUp() &&
      !LongIsOpen(USER_MAGIC_THREE_INSIDE_UP)
   ){
      OpenLong(
         CalculatePositionSize(USER_MAGIC_THREE_INSIDE_UP),
         USER_MAGIC_THREE_INSIDE_UP,
         CalculateSL(USER_MAGIC_THREE_INSIDE_UP),
         USER_TAKE_PROFIT);
   }

   if (
      LongIsOpen(USER_MAGIC_THREE_INSIDE_UP) &&
      AllBearishPatterns()
   ){
      int ticket = FindLong(USER_MAGIC_THREE_INSIDE_UP);
      CloseLong(ticket, CalculatePositionSize(USER_MAGIC_THREE_INSIDE_UP));
   }
   
   //+---------------------------------------------------------------+
   //| Three Inside Down                                             |
   //+---------------------------------------------------------------+
   if (
      OpenThreeInsideDown() &&
      !ShortIsOpen(USER_MAGIC_THREE_INSIDE_DOWN)
   ){
      OpenShort(
         CalculatePositionSize(USER_MAGIC_THREE_INSIDE_DOWN),
         USER_MAGIC_THREE_INSIDE_DOWN,
         CalculateSL(USER_MAGIC_THREE_INSIDE_DOWN),
         USER_TAKE_PROFIT);
   }
 
   if (
      ShortIsOpen(USER_MAGIC_THREE_INSIDE_DOWN) &&
      AllBullishPatterns()
   ){
      int ticket = FindShort(USER_MAGIC_THREE_INSIDE_DOWN);
      CloseShort(ticket, CalculatePositionSize(USER_MAGIC_THREE_INSIDE_DOWN));
   }  
   
}

//+------------------------------------------------------------------+
//| User function NewBar()                                           |
//| Returns true when a new bar has just formed                      |
//+------------------------------------------------------------------+
void Log()
{
   if (USER_LOGGER_DEBUG)
   {
   }
}

//+------------------------------------------------------------------+
//| User function NewBar()                                           |
//| Returns true when a new bar has just formed                      |
//+------------------------------------------------------------------+
bool NewBar()
{
   static datetime newTime=0;
   if (newTime!=Time[0])
   {
      newTime = Time[0];
      return true;
   } else {
      return false;
   }
}

//+------------------------------------------------------------------+
//| User functions for candlestick patterns:                         |
//| Common Functions                                                 |
//+------------------------------------------------------------------+

bool IsGreen(int shift) // IsWhite
{
   return (Open[shift] < Close[shift]);
}

bool IsRed(int shift)   // IsBlack
{
   return (Open[shift] > Close[shift]);
}

double LengthOC(int shift)
{
   return MathAbs(Open[shift] - Close[shift]);
}

double LengthHL(int shift)
{
   return MathAbs(High[shift] - Low[shift]);
}

bool IsHighest(int shift)
{
   double lengthOC = LengthOC(shift);
   
   if (IsGreen(shift)) {
      for (int i=shift; i<shift+USER_BACK_PERIODS; i++)
         if (High[i] > Close[shift] + lengthOC)
            return false;
      return true;
   } else {
      for (int i=shift; i<shift+USER_BACK_PERIODS; i++)
         if (High[i] > Open[shift] + lengthOC)
            return false;
      return true;   
   }
}

bool IsLowest(int shift)
{
   double lengthOC = LengthOC(shift);
   
   if (IsGreen(shift)) {
      for (int i=shift; i<shift+USER_BACK_PERIODS; i++)
         if (Low[i] < Open[shift] - lengthOC)
            return false;
      return true;
   } else {
      for (int i=shift; i<shift+USER_BACK_PERIODS; i++)
         if (Low[i] < Close[shift] - lengthOC)
            return false;
      return true;   
   }
}


//+------------------------------------------------------------------+
//| User functions for candlestick patterns:                         |
//| Bullish Engulfing and Bearish Engulfing                          |
//+------------------------------------------------------------------+
bool BullishEngulfing(int shift)
{
   return (
      IsRed(shift+1) &&
      IsGreen(shift) &&
      Close[shift] > Open[shift+1] 
   );
}

bool BearishEngulfing(int shift)
{
   return (
      IsGreen(shift+1) &&
      IsRed(shift) &&
      Close[shift] < Open[shift+1] 
   );
}

bool OpenBullishEngulfing()
{
   return (
      BullishEngulfing(2) && IsLowest(2) && IsGreen(1)
   );
}

bool OpenBearishEngulfing()
{
   return (
      BearishEngulfing(2) && IsHighest(2) && IsRed(1)
   );
}      


//+------------------------------------------------------------------+
//| User functions for candlestick patterns:                         |
//| Three White Soldiers and Three Black Crows                       |
//+------------------------------------------------------------------+

bool ThreeWhiteSoldiers(int shift)
{
   return (
      IsGreen(shift)   && LengthOC(shift)   > 10 * Point &&
      IsGreen(shift+1) && LengthOC(shift+1) > 10 * Point &&
      IsGreen(shift+2) && LengthOC(shift+2) > 10 * Point
   );
}

bool ThreeBlackCrows(int shift)
{
   return (
      IsRed(shift)   && LengthOC(shift)   > 10 * Point &&
      IsRed(shift+1) && LengthOC(shift+1) > 10 * Point &&
      IsRed(shift+2) && LengthOC(shift+2) > 10 * Point
   );
}

bool OpenThreeWhiteSoldiers()
{
   return (
      ThreeWhiteSoldiers(1) && IsLowest(3)
   );
}

bool OpenThreeBlackCrows()
{
   return (
      ThreeBlackCrows(1) && IsHighest(3)
   );
}

//+------------------------------------------------------------------+
//| User functions for candlestick patterns:                         |
//| Morning Stat and Evening Star                                   |
//+------------------------------------------------------------------+

bool MorningStar(int shift)
{
   return (
      IsRed(shift+2) && LengthOC(shift+2) > 20 * Point &&
                        LengthOC(shift+1) <= 20 * Point &&
      IsGreen(shift) && LengthOC(shift) > LengthOC(shift+2)/2
   );
}

bool EveningStar(int shift)
{
   return (
      IsGreen(shift+2) && LengthOC(shift+2) > 20 * Point &&
                        LengthOC(shift+1) <= 20 * Point &&
      IsRed(shift) && LengthOC(shift) > LengthOC(shift+2)/2
   );
}

bool OpenMorningStar()
{
   return (
      MorningStar(1) && IsLowest(3)
   );
}

bool OpenEveningStar()
{
   return (
      EveningStar(1) && IsHighest(3)
   );
}

//+------------------------------------------------------------------+
//| User functions for candlestick patterns:                         |
//| Three Inside Up and Three Inside Out                             |
//+------------------------------------------------------------------+

bool ThreeInsideUp(int shift)
{
   return (
      IsRed(shift+2)    && LengthOC(shift+2) > 20 * Point &&
      IsGreen(shift+1)  && LengthOC(shift+1) > LengthOC(shift+2)/2 &&
      IsGreen(shift)    && Close[shift] > High[shift+2]
   );
}

bool ThreeInsideDown(int shift)
{
   return (
      IsGreen(shift+2)  && LengthOC(shift+2) > 20 * Point &&
      IsRed(shift+1)    && LengthOC(shift+1) > LengthOC(shift+2)/2 &&
      IsRed(shift)      && Close[shift] < Low[shift+2]
   );
}

bool OpenThreeInsideUp()
{
   return (
      ThreeInsideUp(1) && IsLowest(3)
   );
}

bool OpenThreeInsideDown()
{
   return (
      ThreeInsideDown(1) && IsHighest(3)
   );
}

//+------------------------------------------------------------------+
//| User functions AllBullishPatterns and AllBearishPatterns         |
//| Return true if any of the bearish or bullish candlestick patterns|
//| appears.                                                         |
//+------------------------------------------------------------------+
bool AllBullishPatterns()
{
   return
      OpenBullishEngulfing() ||
      OpenThreeWhiteSoldiers() ||
      OpenMorningStar() ||
      OpenThreeInsideUp();
}

bool AllBearishPatterns()
{
   return
      OpenBearishEngulfing() ||
      OpenThreeBlackCrows() ||
      OpenEveningStar() ||
      OpenThreeInsideDown();
}


//+------------------------------------------------------------------+
//| User function CalculatePositionSize()                            |
//+------------------------------------------------------------------+
double CalculatePositionSize(int magic)
{
   return USER_POSITION;
}

//+------------------------------------------------------------------+
//| User function CalculateSL                                        |
//+------------------------------------------------------------------+
double CalculateSL(int magic)
{
   if (magic == USER_MAGIC_BULLISH_ENGULFING) {
      return (LengthOC(1) + 2 * LengthOC(2));
   } else if (magic == USER_MAGIC_BEARISH_ENGULFING) {
      return (LengthOC(1) + 2 * LengthOC(2));
   } else if (magic == USER_MAGIC_THREE_WHITE_SOLDIERS) {
      return 2 * (Close[1] - Open[3]);
   } else if (magic == USER_MAGIC_THREE_BLACK_CROWS) {
      return 2 * (Open[3] - Close[1]);
   } else if (magic == USER_MAGIC_MORNING_STAR) {
      return LengthOC(3);
   } else if (magic == USER_MAGIC_EVENING_STAR) {
      return LengthOC(3);
   } else if (magic == USER_MAGIC_THREE_INSIDE_UP) {
      return LengthOC(2) + LengthOC(3);
   } else if (magic == USER_MAGIC_THREE_INSIDE_DOWN) {
      return LengthOC(2) + LengthOC(3);
   } else {
      return USER_STOP_LOSS;
   }
}

//+------------------------------------------------------------------+
//| User function CalculateTP                                        |
//+------------------------------------------------------------------+
double CalculateTP(int magic)
{
   return USER_TAKE_PROFIT;
}

//+------------------------------------------------------------------+
//| User function LongIsOpen()                                       |
//| Returns true when a long market order on this security is open   |
//+------------------------------------------------------------------+
bool LongIsOpen(int magic)
{
   for (int i=1; i<=OrdersTotal(); i++)
   {
      if (OrderSelect(i-1, SELECT_BY_POS)==true)
      {
         if (OrderSymbol()!=Symbol()) continue;
         if (OrderType()!=OP_BUY) continue;
         if (OrderMagicNumber()!=magic) continue;
         return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| User function FindLong()                                         |
//| Returns the ticket of an EA long position or -1                  |
//+------------------------------------------------------------------+
int FindLong(int magic)
{
   for (int i=1; i<=OrdersTotal(); i++)
   {
      if (OrderSelect(i-1, SELECT_BY_POS)==true)
      {
         if (OrderSymbol()!=Symbol()) continue;
         if (OrderType()!=OP_BUY) continue;
         if (OrderMagicNumber()!=magic) continue;
         return OrderTicket();
      }
   }
   return -1;
}

//+------------------------------------------------------------------+
//| User function ShortIsOpen()                                       |
//| Returns true when a short market order on this security is open  |
//+------------------------------------------------------------------+
bool ShortIsOpen(int magic)
{
   for (int i=1; i<=OrdersTotal(); i++)
   {
      if (OrderSelect(i-1, SELECT_BY_POS)==true)
      {
         if (OrderSymbol()!=Symbol()) continue;
         if (OrderType()!=OP_SELL) continue;
         if (OrderMagicNumber()!=magic) continue;
         return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| User function FindShort()                                        |
//| Returns the ticket of an EA short position or -1                 |
//+------------------------------------------------------------------+
int FindShort(int magic)
{
   for (int i=1; i<=OrdersTotal(); i++)
   {
      if (OrderSelect(i-1, SELECT_BY_POS)==true)
      {
         if (OrderSymbol()!=Symbol()) continue;
         if (OrderType()!=OP_SELL) continue;
         if (OrderMagicNumber()!=magic) continue;
         return OrderTicket();
      }
   }
   return -1;
}

//+------------------------------------------------------------------+
//| User function FindPositionSize()                                 |
//| Return the position size of an open order, or -1.0 if order is   |
//| not found                                                        |
//+------------------------------------------------------------------+
double FindPositionSize(int ticket)
{
      bool select = OrderSelect(ticket, SELECT_BY_TICKET);
      if (!select)
      {
         return -1.0;
      }
      return OrderLots();
}

//+------------------------------------------------------------------+
//| User function FindOpenPrice()                                    |
//| Return the opening price of an open order, or -1.0 if order is   |
//| not found                                                        |
//+------------------------------------------------------------------+
double FindOpenPrice(int ticket)
{
      bool select = OrderSelect(ticket, SELECT_BY_TICKET);
      if (!select)
      {
         return -1.0;
      }
      return OrderOpenPrice();
}

//+------------------------------------------------------------------+
//| User function FindStopLoss()                                     |
//| Return the StopLoss of an open order, or -1.0 if order is        |
//| not found                                                        |
//+------------------------------------------------------------------+
double FindStopLoss(int ticket)
{
      bool select = OrderSelect(ticket, SELECT_BY_TICKET);
      if (!select)
      {
         return -1.0;
      }
      return OrderStopLoss();
}

//+------------------------------------------------------------------+
//| User function TrailSL                                            |
//+------------------------------------------------------------------+
void TrailSL(int magic)
{
  // Check to trail S/L
   if (LongIsOpen(magic))
   {
      int ticketLong = FindLong(magic);
      double openPrice = FindOpenPrice(ticketLong);
      double stopLoss = FindStopLoss(ticketLong);
      if (
            Open[0] - stopLoss > 2 * USER_TRAIL_STOP_LOSS
         )
      {
         TrailStopLoss(ticketLong, NormalizeDouble(stopLoss + USER_TRAIL_STOP_LOSS + 30 * Point, Digits));
      }
   }
   
   // Check to trail S/L
   if (ShortIsOpen(magic))
   {
      int ticketShort = FindShort(magic);
      double openPrice = FindOpenPrice(ticketShort);
      double stopLoss = FindStopLoss(ticketShort);
      if (
            stopLoss - Open[0] > 2 * USER_TRAIL_STOP_LOSS
         )
      {
         TrailStopLoss(ticketShort, NormalizeDouble(stopLoss - USER_TRAIL_STOP_LOSS - 30 * Point, Digits));
      }
   }
}

//+------------------------------------------------------------------+
//| User function OpenLong()                                         |
//| Send a market buy order                                          |
//+------------------------------------------------------------------+
int OpenLong(double positionSize, int magic, double SL, double TP)
{
   int ticket=-1;
   while (true)
   {
      ticket = OrderSend(
         Symbol(),
         OP_BUY,
         positionSize,
         Ask,
         3,
         Bid-SL,
         Bid+TP,
         "CandlestickPatterns",
         magic);
      if (ticket>0)
         break;
      int Error=GetLastError();
      switch(Error)  // Overcomable errors
      {
         case 135:Alert("OpenLong ", Symbol(), ": Error ", Error,
            " ", ErrorDescription(Error), ". Retrying...");
            RefreshRates();
            continue;
         case 136:Alert("OpenLong ", Symbol(), ": Error ", Error,
            " ", ErrorDescription(Error), ". Waiting for a new tick...");
            while(RefreshRates()==false)
               Sleep(1);
            continue;
         case 146:Alert("OpenLong ", Symbol(), ": Error ", Error,
            " ", ErrorDescription(Error), ". Retrying...");
            Sleep(500);
            RefreshRates();
            continue;
      }
      Alert("OpenLong ", Symbol(), ": Ask=", Ask,", SL=",
         Bid-USER_STOP_LOSS, ", TP=", Bid+USER_TAKE_PROFIT);
      Alert("OpenLong ", Symbol(), ": Error ", Error,
         " ", ErrorDescription(Error));
      break;
   }
   return ticket;
}

//+------------------------------------------------------------------+
//| User function OpenShort()                                        |
//| Send a market sell order                                         |
//+------------------------------------------------------------------+
int OpenShort(double positionSize, int magic, double SL, double TP)
{
   int ticket=-1;
   while (true)
   {
      ticket = OrderSend(
         Symbol(),
         OP_SELL,
         positionSize,
         Bid,
         3,
         Ask+SL,
         Ask-TP,
         "CandlestickPatterns",
         magic);
      if (ticket>0)
         break;
      int Error=GetLastError();
      switch(Error)  // Overcomable errors
      {
         case 135:Alert("OpenShort ", Symbol(), ": Error ", Error,
            " ", ErrorDescription(Error), ". Retrying...");
            RefreshRates();
            continue;
         case 136:Alert("OpenShort ", Symbol(), ": Error ", Error,
            " ", ErrorDescription(Error), ". Waiting for a new tick...");
            while(RefreshRates()==false)
               Sleep(1);
            continue;
         case 146:Alert("OpenShort ", Symbol(), ": Error ", Error,
            " ", ErrorDescription(Error), ". Retrying...");
            Sleep(500);
            RefreshRates();
            continue;
      }
      Alert("OpenShort ", Symbol(), ": Bid=", Bid, ", SL=",
         Ask+USER_STOP_LOSS, ", TP=", Ask-USER_TAKE_PROFIT);
      Alert("OpenShort ", Symbol(), ": Error ", Error,
         " ", ErrorDescription(Error));
      break;
   }
   return ticket;
}

//+------------------------------------------------------------------+
//| User function CloseLong()                                        |
//| Close a market buy order                                         |
//+------------------------------------------------------------------+
void CloseLong(int ticket, double positionSize)
{
   while (true)
   {
      bool success = OrderClose(ticket, positionSize, Bid, 3);
      if (success)
         break;
      int Error=GetLastError();
      switch(Error)  // Overcomable errors
      {
         case 135:Alert("CloseLong #", ticket, ": Error ", Error,
            " ", ErrorDescription(Error), ". Retrying..");
            RefreshRates();
            continue;
         case 136:Alert("CloseLong #", ticket, ": Error ", Error,
            " ", ErrorDescription(Error), ". Waiting for a new tick..");
            while(RefreshRates()==false)
               Sleep(1);
            continue;
         case 146:Alert("CloseLong #", ticket, ": Error ", Error,
            " ", ErrorDescription(Error), ". Retrying..");
            Sleep(500);
            RefreshRates();
            continue;
      }
      Alert("CloseLong #", ticket, ": Error ", Error,
         " ", ErrorDescription(Error));
      break;
   }
}

//+------------------------------------------------------------------+
//| User function CloseShort()                                       |
//| Close a market sell order                                        |
//+------------------------------------------------------------------+
void CloseShort(int ticket, double positionSize)
{
   while (true)
   {
      bool success = OrderClose(ticket, positionSize, Ask, 3);
      if (success)
         break;
      int Error=GetLastError();
      switch(Error)  // Overcomable errors
      {
         case 135:Alert("CloseShort #", ticket, ": Error ", Error,
            " ", ErrorDescription(Error), ". Retrying..");
            RefreshRates();
            continue;
         case 136:Alert("CloseShort #", ticket, ": Error ", Error,
            " ", ErrorDescription(Error), ". Waiting for a new tick..");
            while(RefreshRates()==false)
               Sleep(1);
            continue;
         case 146:Alert("CloseShort #", ticket, ": Error ", Error,
            " ", ErrorDescription(Error), ". Retrying..");
            Sleep(500);
            RefreshRates();
            continue;
      }
      Alert("CloseShort #", ticket, ": Error ", Error,
         " ", ErrorDescription(Error));
      break;
   }
}

//+------------------------------------------------------------------+
//| User function TrailStopLoss()                                    |
//| Modify the SL of an open market order                            |
//+------------------------------------------------------------------+
void TrailStopLoss(int ticket, double SL)
{
   while (true)
   {
      bool select = OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
      if (!select)
      {
         Alert("TrailStopLoss #", ticket, ": Error: Could not select order");
         break;
      }
      bool success = OrderModify(ticket, OrderOpenPrice(), SL, OrderTakeProfit(), 0);
      if (success)
         break;
      int Error=GetLastError();
      switch(Error)  // Overcomable errors
      {
         case 135:Alert("TrailStopLoss #", ticket, ": Error ", Error,
            " ", ErrorDescription(Error), ". Retrying..");
            RefreshRates();
            continue;
         case 136:Alert("TrailStopLoss #", ticket, ": Error ", Error,
            " ", ErrorDescription(Error), ". Waiting for a new tick..");
            while(RefreshRates()==false)
               Sleep(1);
            continue;
         case 146:Alert("TrailStopLoss #", ticket, ": Error ", Error,
            " ", ErrorDescription(Error), ". Retrying..");
            Sleep(500);
            RefreshRates();
            continue;
      }
      Alert("TrailStopLoss #", ticket, ": Error ", Error,
         " ", ErrorDescription(Error));
      break;
   }
}