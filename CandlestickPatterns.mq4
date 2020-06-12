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
//| o Three White Soldiers (1002) and Three Black Crows (1003)       |
//| o Morning (1004) and Evening (1005) Star                         |
//|                                                                  |
//| The rules applied by this EA are:                                |
//| o Whenever a pattern is detected, a trade opens in the direction |
//|   the pattern dictates, unless a trade is already open for that  |
//|   pattern.                                                       |
//| o Stop loss is calculated for each pattern, the general rule is  |
//|   that the SL is set away from the first candlestick at the      |
//|   pattern's height, but there are variations. Check the code.    |
//| o Take Profit is fixed to USER_TAKE_PROFIT for all patterns.     |
//| o Trailing SL and TP rules:                                      |
//|   - At 1/3 the distance to TP, SL is moved to OP.                |
//|   - At 2/3 the distance to TP, SL is moved to 1/3 distance to TP |
//|     and TP 1/3 the distance further                              |
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
int USER_MAGIC_THREE_WHITE_SOLDIERS=1002;
int USER_MAGIC_THREE_BLACK_CROWS=1003;
int USER_MAGIC_MORNING_STAR=1004;
int USER_MAGIC_EVENING_STAR=1005;
extern int USER_TAKE_PROFIT_PIPS=1000;                               // Default Take Profit in pips
extern int USER_STOP_LOSS_PIPS=150;                                  // Default Stop Loss in pips
extern double USER_POSITION=0.01;                                    // Base of position size calculations
extern bool ENABLE_THREE_WHITE_SOLDIERS=true;
extern bool ENABLE_THREE_BLACK_CROWS=true;
extern bool ENABLE_MORNING_STAR=true;
extern bool ENABLE_EVENING_STAR=true;
extern bool USER_LOGGER_DEBUG=false;                                 // Enable or disable debug log
extern int USER_BACK_PERIODS=7;                                      // How many periods back to check price for support/resistance

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
   
   Alert("Init Symbol=", Symbol(), ", Default TP=", USER_TAKE_PROFIT,
      ", Default SL=", USER_STOP_LOSS);
   
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
   //| Three White Soldiers                                          |
   //+---------------------------------------------------------------+
   if (
      ENABLE_THREE_WHITE_SOLDIERS &&
      OpenThreeWhiteSoldiers() &&
      !IsOpen(USER_MAGIC_THREE_WHITE_SOLDIERS) &&
      !IsOpen(USER_MAGIC_THREE_BLACK_CROWS)
   ){
      OpenLong(
         CalculatePositionSize(USER_MAGIC_THREE_WHITE_SOLDIERS),
         USER_MAGIC_THREE_WHITE_SOLDIERS,
         "3 White Soldiers",
         CalculateSL(USER_MAGIC_THREE_WHITE_SOLDIERS),
         CalculateTP(USER_MAGIC_THREE_WHITE_SOLDIERS));
   }

   if (
      LongIsOpen(USER_MAGIC_THREE_WHITE_SOLDIERS) &&
      false
   ){
      int ticket = FindLong(USER_MAGIC_THREE_WHITE_SOLDIERS);
      CloseLong(ticket, CalculatePositionSize(USER_MAGIC_THREE_WHITE_SOLDIERS));
   }
   
   //+---------------------------------------------------------------+
   //| Three Black Crows                                             |
   //+---------------------------------------------------------------+
   if (
      ENABLE_THREE_BLACK_CROWS &&
      OpenThreeBlackCrows() &&
      !IsOpen(USER_MAGIC_THREE_WHITE_SOLDIERS) &&
      !IsOpen(USER_MAGIC_THREE_BLACK_CROWS)
   ){
      OpenShort(
         CalculatePositionSize(USER_MAGIC_THREE_BLACK_CROWS),
         USER_MAGIC_THREE_BLACK_CROWS,
         "3 Black Crows",
         CalculateSL(USER_MAGIC_THREE_BLACK_CROWS),
         CalculateTP(USER_MAGIC_THREE_BLACK_CROWS));
   }
 
   if (
      ShortIsOpen(USER_MAGIC_THREE_BLACK_CROWS) &&
      false
   ){
      int ticket = FindShort(USER_MAGIC_THREE_BLACK_CROWS);
      CloseShort(ticket, CalculatePositionSize(USER_MAGIC_THREE_BLACK_CROWS));
   }   
   
   //+---------------------------------------------------------------+
   //| Morning Star                                                  |
   //+---------------------------------------------------------------+
   if (
      ENABLE_MORNING_STAR &&
      OpenMorningStar() &&
      !IsOpen(USER_MAGIC_MORNING_STAR) &&
      !IsOpen(USER_MAGIC_EVENING_STAR)
   ){
      OpenLong(
         CalculatePositionSize(USER_MAGIC_MORNING_STAR),
         USER_MAGIC_MORNING_STAR,
         "Morning Star",
         CalculateSL(USER_MAGIC_MORNING_STAR),
         CalculateTP(USER_MAGIC_MORNING_STAR));
   }

   if (
      LongIsOpen(USER_MAGIC_MORNING_STAR) &&
      false
   ){
      int ticket = FindLong(USER_MAGIC_MORNING_STAR);
      CloseLong(ticket, CalculatePositionSize(USER_MAGIC_MORNING_STAR));
   }
   
   //+---------------------------------------------------------------+
   //| Evening Star                                                  |
   //+---------------------------------------------------------------+
   if (
      ENABLE_EVENING_STAR &&
      OpenEveningStar() &&
      !IsOpen(USER_MAGIC_EVENING_STAR) &&
      !IsOpen(USER_MAGIC_MORNING_STAR)
   ){
      OpenShort(
         CalculatePositionSize(USER_MAGIC_EVENING_STAR),
         USER_MAGIC_EVENING_STAR,
         "Evening Star",
         CalculateSL(USER_MAGIC_EVENING_STAR),
         CalculateTP(USER_MAGIC_EVENING_STAR));
   }
 
   if (
      ShortIsOpen(USER_MAGIC_EVENING_STAR) &&
      false
   ){
      int ticket = FindShort(USER_MAGIC_EVENING_STAR);
      CloseShort(ticket, CalculatePositionSize(USER_MAGIC_EVENING_STAR));
   }  
   

   //+---------------------------------------------------------------+
   //| Trail S/L for all open positions                              |
   //+---------------------------------------------------------------+
   TrailSL(USER_MAGIC_EVENING_STAR);
   TrailSL(USER_MAGIC_MORNING_STAR);
   TrailSL(USER_MAGIC_THREE_BLACK_CROWS);
   TrailSL(USER_MAGIC_THREE_WHITE_SOLDIERS);
  
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

bool IsHighest(int shift, int backPeriods)
{
   for (int i=shift+2; i<shift+backPeriods; i++)
   {
      if (High[i] > High[shift])
         return false;
   }
   return true;
}

bool IsLowest(int shift, int backPeriods)
{
   for (int i=shift+2; i<shift+backPeriods; i++)
   {
      if (Low[i] < Low[shift])
         return false;
   }
   return true;
}
//+------------------------------------------------------------------+
//| User functions for candlestick patterns:                         |
//| Three White Soldiers and Three Black Crows                       |
//+------------------------------------------------------------------+

bool ThreeWhiteSoldiers(int shift)
{
   return (
      IsGreen(shift)   &&
      IsGreen(shift+1) &&
      IsGreen(shift+2)
   );
}

bool ThreeBlackCrows(int shift)
{
   return (
      IsRed(shift)   &&
      IsRed(shift+1) &&
      IsRed(shift+2)
   );
}

bool OpenThreeWhiteSoldiers()
{
   return (
      ThreeWhiteSoldiers(1) && IsLowest(3, USER_BACK_PERIODS)
   );
}

bool OpenThreeBlackCrows()
{
   return (
      ThreeBlackCrows(1) && IsHighest(3, USER_BACK_PERIODS)
   );
}

//+------------------------------------------------------------------+
//| User functions for candlestick patterns:                         |
//| Morning Stat and Evening Star                                   |
//+------------------------------------------------------------------+

bool MorningStar(int shift)
{
   return (
      IsRed(shift+2) && LengthOC(shift+2) > 40 * Point &&
                        LengthOC(shift+1) <= 20 * Point &&
      IsGreen(shift+0) && LengthOC(shift+0) > LengthOC(shift+2)/2 &&
      High[shift+1] < Close[shift+0]
   );
}

bool EveningStar(int shift)
{
   return (
      IsGreen(shift+2) && LengthOC(shift+2) > 40 * Point &&
                        LengthOC(shift+1) <= 20 * Point &&
      IsRed(shift+0) && LengthOC(shift+0) > LengthOC(shift+2)/2 &&
      Low[shift+1] > Close[shift+0]
   );
}

bool OpenMorningStar()
{
   return (
      MorningStar(1) && IsLowest(2, USER_BACK_PERIODS)
      
   );
}

bool OpenEveningStar() 
{
   return (
      EveningStar(1) && IsHighest(2, USER_BACK_PERIODS)
   );
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
   if (magic == USER_MAGIC_THREE_WHITE_SOLDIERS) {
      return LengthOC(1) + LengthOC(2) + LengthOC(3);
   } else if (magic == USER_MAGIC_THREE_BLACK_CROWS) {
      return LengthOC(1) + LengthOC(2) + LengthOC(3);
   } else if (magic == USER_MAGIC_MORNING_STAR) {
      return USER_STOP_LOSS;
   } else if (magic == USER_MAGIC_EVENING_STAR) {
      return USER_STOP_LOSS;
   } else {
      return USER_STOP_LOSS;
   }
}

//+------------------------------------------------------------------+
//| User function CalculateTP                                        |
//+------------------------------------------------------------------+
double CalculateTP(int magic)
{
   if (magic == USER_MAGIC_THREE_WHITE_SOLDIERS) {
      return USER_TAKE_PROFIT;
   } else if (magic == USER_MAGIC_THREE_BLACK_CROWS) {
      return USER_TAKE_PROFIT;
   } else if (magic == USER_MAGIC_MORNING_STAR) {
      return USER_TAKE_PROFIT;
   } else if (magic == USER_MAGIC_EVENING_STAR) {
      return USER_TAKE_PROFIT;
   } else {
      return USER_TAKE_PROFIT;
   }
}

//+------------------------------------------------------------------+
//| User function IsOpen()                                           |
//| Returns true when a  market order on this security is open       |
//+------------------------------------------------------------------+
bool IsOpen(int magic)
{
   for (int i=1; i<=OrdersTotal(); i++)
   {
      if (OrderSelect(i-1, SELECT_BY_POS)==true)
      {
         if (OrderSymbol()!=Symbol()) continue;
         if (OrderMagicNumber()!=magic) continue;
         return true;
      }
   }
   return false;
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
//| User function FindTakeProfit()                                   |
//| Return the TakeProfit of an open order, or -1.0 if order is      |
//| not found                                                        |
//+------------------------------------------------------------------+
double FindTakeProfit(int ticket)
{
      bool select = OrderSelect(ticket, SELECT_BY_TICKET);
      if (!select)
      {
         return -1.0;
      }
      return OrderTakeProfit();
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
      double takeProfit = FindTakeProfit(ticketLong);
      double stopLoss = FindStopLoss(ticketLong);
      if (
            Open[0] > openPrice &&
            MathAbs(Open[0] - openPrice) > MathAbs(takeProfit - openPrice) / 3 &&
            stopLoss < openPrice
         )
      {
         TrailStopLoss(ticketLong, NormalizeDouble(openPrice, Digits));
      }
      if (
            Open[0] > openPrice &&
            MathAbs(Open[0] - openPrice) > 2 * MathAbs(takeProfit - openPrice) / 3 &&
            stopLoss <= openPrice
         )
      {
         TrailStopLoss(ticketLong, NormalizeDouble(openPrice + MathAbs(takeProfit - openPrice)/3, Digits));
         MoveTakeProfit(ticketLong, NormalizeDouble(takeProfit + MathAbs(takeProfit - openPrice)/3, Digits));
      }
   }
   
   // Check to trail S/L
   if (ShortIsOpen(magic))
   {
      int ticketShort = FindShort(magic);
      double openPrice = FindOpenPrice(ticketShort);
      double takeProfit = FindTakeProfit(ticketShort);
      double stopLoss = FindStopLoss(ticketShort);
      if (
            Open[0] < openPrice &&
            MathAbs(Open[0] - openPrice) > MathAbs(takeProfit - openPrice) / 3 &&
            stopLoss > openPrice
         )
      {
         TrailStopLoss(ticketShort, NormalizeDouble(openPrice, Digits));
      }
      if (
            Open[0] < openPrice &&
            MathAbs(Open[0] - openPrice) > 2 * MathAbs(takeProfit - openPrice) / 3 &&
            stopLoss >= openPrice
         )
      {
         TrailStopLoss(ticketShort, NormalizeDouble(openPrice - MathAbs(takeProfit - openPrice)/3, Digits));
         MoveTakeProfit(ticketShort, NormalizeDouble(takeProfit - MathAbs(takeProfit - openPrice)/3, Digits));
      }
   }
}

//+------------------------------------------------------------------+
//| User function OpenLong()                                         |
//| Send a market buy order                                          |
//+------------------------------------------------------------------+
int OpenLong(double positionSize, int magic, string magicName, double SL, double TP)
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
         magicName,
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
         Bid-SL, ", TP=", Bid+TP);
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
int OpenShort(double positionSize, int magic, string magicName, double SL, double TP)
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
         magicName,
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
         Ask+SL, ", TP=", Ask-TP);
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

//+------------------------------------------------------------------+
//| User function MoveTakeProfit()                                   |
//| Modify the TP of an open market order                            |
//+------------------------------------------------------------------+
void MoveTakeProfit(int ticket, double TP)
{
   while (true)
   {
      bool select = OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
      if (!select)
      {
         Alert("MoveTakeProfit #", ticket, ": Error: Could not select order");
         break;
      }
      bool success = OrderModify(ticket, OrderOpenPrice(), OrderStopLoss(), TP, 0);
      if (success)
         break;
      int Error=GetLastError();
      switch(Error)  // Overcomable errors
      {
         case 135:Alert("MoveTakeProfit #", ticket, ": Error ", Error,
            " ", ErrorDescription(Error), ". Retrying..");
            RefreshRates();
            continue;
         case 136:Alert("MoveTakeProfit #", ticket, ": Error ", Error,
            " ", ErrorDescription(Error), ". Waiting for a new tick..");
            while(RefreshRates()==false)
               Sleep(1);
            continue;
         case 146:Alert("MoveTakeProfit #", ticket, ": Error ", Error,
            " ", ErrorDescription(Error), ". Retrying..");
            Sleep(500);
            RefreshRates();
            continue;
      }
      Alert("MoveTakeProfit #", ticket, ": Error ", Error,
         " ", ErrorDescription(Error));
      break;
   }
}
