//+------------------------------------------------------------------+
//|                                                    MATrigger.mq4 |
//|                                              lefterisk@gmail.com |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
//| This EA works with the 24 period SMA and the 48 period SMA on the|
//| hourly chart.The rules are:                                      |
//| When the 24th crosses above the 48th, it goes long.              |
//| When the 24th crosses below the 48th it goes short.              |
//| When the price reaches the 2/3 of distance between open price and|
//| take profit, it movess the SL USER_STOP_LOSS_PIPS above/below    |
//| open price, and at the same time it opens another trade in the   |
//| same direction.                                                  |
//| It works for EURUSD and GBPUSD.                                  |
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
int USER_MAGIC_LONG=901;                                             // Identifies this EA's long positions
int USER_MAGIC_SHORT=902;                                            // Identifies this EA's short positions
extern int USER_TAKE_PROFIT_PIPS=1000;                               // Take Profit in pips
extern int USER_STOP_LOSS_PIPS=500;                                  // Stop Loss in pips
extern int USER_TRAIL_STOP_LOSS_PIPS=200;                            // Trail Stop Loss distance in pips
extern int USER_SEK_MULTIPLIER=1;                                    // For EURSEK, set to 10.
extern double USER_POSITION=0.01;                                    // Position size
extern bool USER_LOGGER_DEBUG=false;                                 // Enable or disable debug log

//+------------------------------------------------------------------+
//| Indicator variables, re-calculated on every new bar.             |
//+------------------------------------------------------------------+
double shortSMA = 0.0, shortSMA_prev = 0.0;
double longSMA = 0.0, longSMA_prev = 0.0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   USER_TAKE_PROFIT = USER_SEK_MULTIPLIER * USER_TAKE_PROFIT_PIPS * Point;
   USER_STOP_LOSS = USER_SEK_MULTIPLIER * USER_STOP_LOSS_PIPS * Point;
   USER_TRAIL_STOP_LOSS = USER_SEK_MULTIPLIER * USER_TRAIL_STOP_LOSS_PIPS * Point;
   
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
      
   // Re-calculate indicators
   shortSMA = NormalizeDouble(iMA(NULL, 0, 24, 0, MODE_SMA, PRICE_CLOSE, 1), Digits);
   shortSMA_prev = NormalizeDouble(iMA(NULL, 0, 24, 0, MODE_SMA, PRICE_CLOSE, 2), Digits);
   longSMA = NormalizeDouble(iMA(NULL, 0, 48, 0, MODE_SMA, PRICE_CLOSE, 1), Digits);
   longSMA_prev = NormalizeDouble(iMA(NULL, 0, 48, 0, MODE_SMA, PRICE_CLOSE, 2), Digits);
   
   Log();
      
   // Check conditions to open long
   if (UptrendOpeningConfirmed() && !LongIsOpen(USER_MAGIC_LONG))
   {
      OpenLong(
         CalculatePositionSize(USER_MAGIC_LONG),
         USER_MAGIC_LONG,
         USER_STOP_LOSS,
         USER_TAKE_PROFIT);
   }

   // Check conditions to open short
   if (DowntrendOpeningConfirmed() && !ShortIsOpen(USER_MAGIC_SHORT))
   {
      OpenShort(
         CalculatePositionSize(USER_MAGIC_SHORT),
         USER_MAGIC_SHORT,
         USER_STOP_LOSS,
         USER_TAKE_PROFIT);
   }
   
   TrailSL(USER_MAGIC_LONG);
   TrailSL(USER_MAGIC_SHORT);

}

//+------------------------------------------------------------------+
//| User function NewBar()                                           |
//| Returns true when a new bar has just formed                      |
//+------------------------------------------------------------------+
void Log()
{
   if (USER_LOGGER_DEBUG)
   {
      Print(Symbol(), ": shortSMA=", shortSMA, ", longSMA=", longSMA);
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
//| User function UptrendConfirmed()                                 |
//| Returns true when long opening conditions are met according to   |
//| EA rules                                                         |
//+------------------------------------------------------------------+
bool UptrendOpeningConfirmed()
{  
   return (
         shortSMA > longSMA &&
         shortSMA_prev < longSMA_prev
      );
}

//+------------------------------------------------------------------+
//| User function DowntrendOpeningConfirmed()                        |
//| Returns true when short opening conditions are met according to  |
//| EA rules                                                         |
//+------------------------------------------------------------------+
bool DowntrendOpeningConfirmed()
{
   return (
         shortSMA < longSMA &&
         shortSMA_prev > longSMA_prev
      );
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
void FindLong(int magic, int& longs[])
{
   for (int i=0; i< ArraySize(longs); i++)
      longs[i] = -1;
   int index = 0;
   for (int i=1; i<=OrdersTotal(); i++)
   {
      if (OrderSelect(i-1, SELECT_BY_POS)==true)
      {
         if (OrderSymbol()!=Symbol()) continue;
         if (OrderType()!=OP_BUY) continue;
         if (OrderMagicNumber()!=magic) continue;
         //return OrderTicket();
         longs[index] = OrderTicket();
         index++;
      }
   }
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
void FindShort(int magic, int& shorts[])
{
   for (int i=0; i < ArraySize(shorts); i++)
      shorts[i] = -1;
   int index = 0;
   for (int i=1; i<=OrdersTotal(); i++)
   {
      if (OrderSelect(i-1, SELECT_BY_POS)==true)
      {
         if (OrderSymbol()!=Symbol()) continue;
         if (OrderType()!=OP_SELL) continue;
         if (OrderMagicNumber()!=magic) continue;
         //return OrderTicket();
         shorts[index] = OrderTicket();
         index++;
      }
   }
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
//| User function CalculatePositionSize()                            |
//+------------------------------------------------------------------+
double CalculatePositionSize(int magic)
{
   return USER_POSITION;
}

//+------------------------------------------------------------------+
//| User function TrailSL                                            |
//+------------------------------------------------------------------+
void TrailSL(int magic)
{
   // Check to trail S/L for long
   int longs[10];
   if (LongIsOpen(magic))
   {
      FindLong(magic, longs);
      int i = 0;
      while (longs[i]>-1) {
         int ticketLong = longs[i];
         double openPrice = FindOpenPrice(ticketLong);
         double takeProfit = FindTakeProfit(ticketLong);
         double stopLoss = FindStopLoss(ticketLong);
         if (
               stopLoss < openPrice &&
               MathAbs(Open[0] - openPrice) > 2 * MathAbs(takeProfit - openPrice) / 3
            )
         {
            TrailStopLoss(ticketLong, NormalizeDouble(openPrice + USER_TRAIL_STOP_LOSS, Digits));
            OpenLong(
               CalculatePositionSize(USER_MAGIC_LONG),
               USER_MAGIC_LONG,
               USER_STOP_LOSS,
               USER_TAKE_PROFIT);
         }
         i++;
      }
   }
   
   // Check to trail S/L for short
   int shorts[10];
   if (ShortIsOpen(magic))
   {
      FindShort(magic, shorts);
      int i=0;
      while (shorts[i]>-1) {
         int ticketShort = shorts[i];
         double openPrice = FindOpenPrice(ticketShort);
         double takeProfit = FindTakeProfit(ticketShort);
         double stopLoss = FindStopLoss(ticketShort);
         if (
               stopLoss > openPrice &&
               MathAbs(Open[0] - openPrice) > 2 * MathAbs(takeProfit - openPrice) / 3
            )
         {
            TrailStopLoss(ticketShort, NormalizeDouble(openPrice - USER_TRAIL_STOP_LOSS, Digits));
            OpenShort(
               CalculatePositionSize(USER_MAGIC_SHORT),
               USER_MAGIC_SHORT,
               USER_STOP_LOSS,
               USER_TAKE_PROFIT);
         }
         i++;
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