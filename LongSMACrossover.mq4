//+------------------------------------------------------------------+
//|                                             LongSMACrossover.mq4 |
//|                                              lefterisk@gmail.com |
//|                                              http://www.mql4.com |
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
int USER_MAGIC_LONG=800;                                             // Identifies this EA's long positions
int USER_MAGIC_SHORT=900;                                            // Identifies this EA's short positions
extern int USER_TAKE_PROFIT_PIPS=1000;                               // Take Profit in pips
extern int USER_STOP_LOSS_PIPS=500;                                  // Stop Loss in pips
extern int USER_TRAIL_STOP_LOSS_PIPS=500;                            // Trail Stop Loss distance in pips
extern double USER_POSITION=0.02;                                    // Base of position size calculations
extern int USER_LONG_SMA_PERIODS=1200;                               // Long SMA periods in hours
extern bool USER_LOGGER_DEBUG=false;                                 // Enable or disable debug log

//+------------------------------------------------------------------+
//| Indicator variables, re-calculated on every new bar.             |
//+------------------------------------------------------------------+
double shortSMA = 0.0;
double mediumSMA = 0.0;
double longSMA = 0.0;
double stoch = 0.0;

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
      
   // Re-calculate indicators
   shortSMA = NormalizeDouble(iMA(NULL, 0, 240, 0, MODE_SMA, PRICE_CLOSE, 0), Digits);
   mediumSMA = NormalizeDouble(iMA(NULL, 0, 480, 0, MODE_SMA, PRICE_CLOSE, 0), Digits);
   longSMA = NormalizeDouble(iMA(NULL, 0, USER_LONG_SMA_PERIODS, 0, MODE_SMA, PRICE_CLOSE, 0), Digits);
   stoch = iStochastic(NULL, 0, 5, 3, 3, MODE_SMA, STO_LOWHIGH, 0, 0);

   Log();
      
   // Check conditions to close long
   if (!UptrendConfirmed() && LongIsOpen())
   {
      int ticketLong = FindLong();
      CloseLong(ticketLong, FindPositionSize(ticketLong));
   }
      
   // Check conditions to close short
   if (!DowntrendConfirmed() && ShortIsOpen())
   {
      int ticketShort = FindShort();
      CloseShort(ticketShort, FindPositionSize(ticketShort));
   }
   
   // Check conditions to open long
   if (UptrendOpeningConfirmed() && !LongIsOpen())
   {
      OpenLong(CalculatePositionSize());
   }

   // Check conditions to open short
   if (DowntrendOpeningConfirmed() && !ShortIsOpen())
   {
      OpenShort(CalculatePositionSize());
   }
   
   // Check to trail S/L
   if (LongIsOpen())
   {
      int ticketLong = FindLong();
      double openPrice = FindOpenPrice(ticketLong);
      double stopLoss = FindStopLoss(ticketLong);
      if (
            Open[0] - openPrice > USER_TRAIL_STOP_LOSS &&
            stopLoss < openPrice
         )
         
      {
         TrailStopLoss(ticketLong,
            NormalizeDouble(openPrice + 30 * Point, Digits));
      }
   }
   
   // Check to trail S/L
   if (ShortIsOpen())
   {
      int ticketShort = FindShort();
      double openPrice = FindOpenPrice(ticketShort);
      double stopLoss = FindStopLoss(ticketShort);
      if (
            openPrice - Open[0] > USER_TRAIL_STOP_LOSS &&
            stopLoss > openPrice
         )
      {
         TrailStopLoss(ticketShort,
            NormalizeDouble(openPrice - 30 * Point, Digits));
      }
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
      Print(Symbol(), ": shortSMA=", shortSMA, ", mediumSMA=", mediumSMA,
            ", longSMA=", longSMA);
      Print(Symbol(), ": UptrendOpening: ", UptrendOpeningConfirmed(),
         ", DowntrendOpening: ", DowntrendOpeningConfirmed(),
         ", Uptrend: ", UptrendConfirmed(),
         ", Downtrend: ", DowntrendConfirmed(),
         ", LongIsOpen: ",LongIsOpen(),
         ", ShortIsOpen: ", ShortIsOpen());
      Print(Symbol(), ": CalculatePositionSize=", CalculatePositionSize(),
         ", FindPositionSizeLong=", FindPositionSize(FindLong()),
         ", FindPositionSizeShort=", FindPositionSize(FindShort()));
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
         Open[1] < longSMA &&
         Close[1] > longSMA
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
         Open[1] > longSMA &&
         Close[1] < longSMA
      );
}


//+------------------------------------------------------------------+
//| User function UptrendConfirmed()                                 |
//| Returns true when an uptrend is confirmed according to EA rules  |
//+------------------------------------------------------------------+
bool UptrendConfirmed()
{
   return (Open[0] > longSMA);
}

//+------------------------------------------------------------------+
//| User function DowntrendConfirmed()                               |
//| Returns true when a downtrend is confirmed according to EA rules |
//+------------------------------------------------------------------+
bool DowntrendConfirmed()
{
   return (Open[0] < longSMA);
}

//+------------------------------------------------------------------+
//| User function LongIsOpen()                                       |
//| Returns true when a long market order on this security is open   |
//+------------------------------------------------------------------+
bool LongIsOpen()
{
   for (int i=1; i<=OrdersTotal(); i++)
   {
      if (OrderSelect(i-1, SELECT_BY_POS)==true)
      {
         if (OrderSymbol()!=Symbol()) continue;
         if (OrderType()!=OP_BUY) continue;
         if (OrderMagicNumber()!=USER_MAGIC_LONG) continue;
         return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| User function FindLong()                                         |
//| Returns the ticket of an EA long position or -1                  |
//+------------------------------------------------------------------+
int FindLong()
{
   for (int i=1; i<=OrdersTotal(); i++)
   {
      if (OrderSelect(i-1, SELECT_BY_POS)==true)
      {
         if (OrderSymbol()!=Symbol()) continue;
         if (OrderType()!=OP_BUY) continue;
         if (OrderMagicNumber()!=USER_MAGIC_LONG) continue;
         return OrderTicket();
      }
   }
   return -1;
}

//+------------------------------------------------------------------+
//| User function ShortIsOpen()                                       |
//| Returns true when a short market order on this security is open  |
//+------------------------------------------------------------------+
bool ShortIsOpen()
{
   for (int i=1; i<=OrdersTotal(); i++)
   {
      if (OrderSelect(i-1, SELECT_BY_POS)==true)
      {
         if (OrderSymbol()!=Symbol()) continue;
         if (OrderType()!=OP_SELL) continue;
         if (OrderMagicNumber()!=USER_MAGIC_SHORT) continue;
         return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| User function FindShort()                                        |
//| Returns the ticket of an EA short position or -1                 |
//+------------------------------------------------------------------+
int FindShort()
{
   for (int i=1; i<=OrdersTotal(); i++)
   {
      if (OrderSelect(i-1, SELECT_BY_POS)==true)
      {
         if (OrderSymbol()!=Symbol()) continue;
         if (OrderType()!=OP_SELL) continue;
         if (OrderMagicNumber()!=USER_MAGIC_SHORT) continue;
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
//| User function CalculatePositionSize()                            |
//+------------------------------------------------------------------+
double CalculatePositionSize()
{
   return USER_POSITION;
}

//+------------------------------------------------------------------+
//| User function OpenLong()                                         |
//| Send a market buy order                                          |
//+------------------------------------------------------------------+
int OpenLong(double positionSize)
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
         Bid-USER_STOP_LOSS,
         Bid+USER_TAKE_PROFIT,
         "LongSMACrossover",
         USER_MAGIC_LONG);
      if (ticket>0)
         break;
      int Error=GetLastError();
      switch(Error)  // Overcomable errors
      {
         case 135:Alert("OpenLong ", Symbol(), ": Error ", Error, " ", ErrorDescription(Error), ". Retrying...");
            RefreshRates();
            continue;
         case 136:Alert("OpenLong ", Symbol(), ": Error ", Error, " ", ErrorDescription(Error), ". Waiting for a new tick...");
            while(RefreshRates()==false)
               Sleep(1);
            continue;
         case 146:Alert("OpenLong ", Symbol(), ": Error ", Error, " ", ErrorDescription(Error), ". Retrying...");
            Sleep(500);
            RefreshRates();
            continue;
      }
      Alert("OpenLong ", Symbol(), ": Ask=",Ask,", SL=",Bid-USER_STOP_LOSS,", TP=",Bid+USER_TAKE_PROFIT);
      Alert("OpenLong ", Symbol(), ": Error ", Error, " ", ErrorDescription(Error));
      break;
   }
   return ticket;
}

//+------------------------------------------------------------------+
//| User function OpenShort()                                        |
//| Send a market sell order                                         |
//+------------------------------------------------------------------+
int OpenShort(double positionSize)
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
         Ask+USER_STOP_LOSS,
         Ask-USER_TAKE_PROFIT,
         "LongSMACrossover",
         USER_MAGIC_SHORT);
      if (ticket>0)
         break;
      int Error=GetLastError();
      switch(Error)  // Overcomable errors
      {
         case 135:Alert("OpenShort ", Symbol(), ": Error ", Error, " ", ErrorDescription(Error), ". Retrying...");
            RefreshRates();
            continue;
         case 136:Alert("OpenShort ", Symbol(), ": Error ", Error, " ", ErrorDescription(Error), ". Waiting for a new tick...");
            while(RefreshRates()==false)
               Sleep(1);
            continue;
         case 146:Alert("OpenShort ", Symbol(), ": Error ", Error, " ", ErrorDescription(Error), ". Retrying...");
            Sleep(500);
            RefreshRates();
            continue;
      }
      Alert("OpenShort ", Symbol(), ": Bid=",Bid,", SL=",Ask+USER_STOP_LOSS,", TP=",Ask-USER_TAKE_PROFIT);
      Alert("OpenShort ", Symbol(), ": Error ", Error, " ", ErrorDescription(Error));
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
         case 135:Alert("CloseLong #", ticket, ": Error ", Error, " ", ErrorDescription(Error), ". Retrying..");
            RefreshRates();
            continue;
         case 136:Alert("CloseLong #", ticket, ": Error ", Error, " ", ErrorDescription(Error), ". Waiting for a new tick..");
            while(RefreshRates()==false)
               Sleep(1);
            continue;
         case 146:Alert("CloseLong #", ticket, ": Error ", Error, " ", ErrorDescription(Error), ". Retrying..");
            Sleep(500);
            RefreshRates();
            continue;
      }
      Alert("CloseLong #", ticket, ": Error ", Error, " ", ErrorDescription(Error));
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
         case 135:Alert("CloseShort #", ticket, ": Error ", Error, " ", ErrorDescription(Error), ". Retrying..");
            RefreshRates();
            continue;
         case 136:Alert("CloseShort #", ticket, ": Error ", Error, " ", ErrorDescription(Error), ". Waiting for a new tick..");
            while(RefreshRates()==false)
               Sleep(1);
            continue;
         case 146:Alert("CloseShort #", ticket, ": Error ", Error, " ", ErrorDescription(Error), ". Retrying..");
            Sleep(500);
            RefreshRates();
            continue;
      }
      Alert("CloseShort #", ticket, ": Error ", Error, " ", ErrorDescription(Error));
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
         case 135:Alert("TrailStopLoss #", ticket, ": Error ", Error, " ", ErrorDescription(Error), ". Retrying..");
            RefreshRates();
            continue;
         case 136:Alert("TrailStopLoss #", ticket, ": Error ", Error, " ", ErrorDescription(Error), ". Waiting for a new tick..");
            while(RefreshRates()==false)
               Sleep(1);
            continue;
         case 146:Alert("TrailStopLoss #", ticket, ": Error ", Error, " ", ErrorDescription(Error), ". Retrying..");
            Sleep(500);
            RefreshRates();
            continue;
      }
      Alert("TrailStopLoss #", ticket, ": Error ", Error, " ", ErrorDescription(Error));
      break;
   }
}