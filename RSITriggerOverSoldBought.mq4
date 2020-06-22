//+------------------------------------------------------------------+
//|                                     RSITriggerOverSoldBought.mq4 |
//|                                              lefterisk@gmail.com |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
//| Daily RSI crossing strategy for EURUSD                           |
//| Long when crossing above 30, short when crossing below 70        |
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
int USER_MAGIC_DAILY_LONG=907;                                       // Identifies this EA's long positions
int USER_MAGIC_DAILY_SHORT=908;                                      // Identifies this EA's short positions
extern int USER_TAKE_PROFIT_PIPS=10000;                              // Take Profit in pips
extern int USER_STOP_LOSS_PIPS=1000;                                 // Stop Loss in pips
extern double USER_POSITION=0.01;                                    // Position size
extern bool USER_LOGGER_DEBUG=false;                                 // Enable or disable debug log
extern bool USER_LOGGER_ACTION=false;                                // Enable or disable action log

//+------------------------------------------------------------------+
//| Indicator variables, re-calculated on every new bar.             |
//+------------------------------------------------------------------+
double rsi_1=0.0, rsi_2=0.0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   USER_TAKE_PROFIT = USER_TAKE_PROFIT_PIPS * Point;
   USER_STOP_LOSS = USER_STOP_LOSS_PIPS * Point;
   
   Alert("Init Symbol=", Symbol(),
      ", TP=", USER_TAKE_PROFIT,
      ", SL=", USER_STOP_LOSS);
   
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
      
   debugLog("NewBar");
      
   // Re-calculate indicators
   rsi_1 = NormalizeDouble(iRSI(NULL, 0, 14, PRICE_CLOSE, 1), Digits);
   rsi_2 = NormalizeDouble(iRSI(NULL, 0, 14, PRICE_CLOSE, 2), Digits);
   
   // ----------------------------------------------------
   // Check conditions to open or close long SMA crosses
   // ----------------------------------------------------   
   // Open Long Daily
   if (
      !IsOpen(USER_MAGIC_DAILY_LONG) &&
      OpenRSIOverSoldLong()
   ){
      actionLog("OpenRSIOverSoldLong");
      OpenLong(
         CalculatePositionSize(USER_MAGIC_DAILY_LONG),
         USER_MAGIC_DAILY_LONG,
         "RSITrigger50Cross",
         CalculateSL(USER_MAGIC_DAILY_LONG),
         CalculateTP(USER_MAGIC_DAILY_LONG));
   }
   
   // Close Long Daily
   if (
      IsOpen(USER_MAGIC_DAILY_LONG) &&
      CloseRSIOverSoldLong()
   ){
      actionLog("CloseRSIOverSoldLong");
      int longs[10], i=0;
      FindLong(USER_MAGIC_DAILY_LONG, longs);
      while (longs[i]>-1)
      {
         int ticket = longs[i];
         CloseLong(ticket, CalculatePositionSize(USER_MAGIC_DAILY_LONG));
         i++;
      }
   }

   // ----------------------------------------------------
   // Check conditions to open or close short SMA crosses
   // ----------------------------------------------------   
   // Open Short Daily
   if (
      !IsOpen(USER_MAGIC_DAILY_SHORT) &&
      OpenRSIOverBoughtShort()
   ){
      actionLog("OpenRSIOverBoughtShort");
      OpenShort(
         CalculatePositionSize(USER_MAGIC_DAILY_SHORT),
         USER_MAGIC_DAILY_SHORT,
         "RSITrigger50Cross",
         CalculateSL(USER_MAGIC_DAILY_SHORT),
         CalculateTP(USER_MAGIC_DAILY_SHORT));
   }
   
   // Close Short Daily
   if (
      IsOpen(USER_MAGIC_DAILY_SHORT) &&
      CloseRSIOverBoughtShort()
   ){
      actionLog("CloseRSIOverBoughtShort");
      int shorts[10], i=0;
      FindShort(USER_MAGIC_DAILY_SHORT, shorts);
      while (shorts[i]>-1)
      {
         int ticket = shorts[i];
         CloseShort(ticket, CalculatePositionSize(USER_MAGIC_DAILY_SHORT));
         i++;
      }
   }
}

//+------------------------------------------------------------------+
//| User function NewBar()                                           |
//| Returns true when a new bar has just formed                      |
//+------------------------------------------------------------------+
void Log(string tag)
{
      Print(tag, ": Open[0]=", Open[0]);
      Print(tag, ": rsi_1=", rsi_1, ", rsi_2=", rsi_2);
      Print(tag, ": OpenLong=", OpenRSIOverSoldLong(), ", OpenShort=", OpenRSIOverBoughtShort());
}

void debugLog(string tag)
{
   if (USER_LOGGER_DEBUG)
      Log(tag);
}

void actionLog(string tag)
{
   if (USER_LOGGER_ACTION)
      Log(tag);
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

//+------------------------------------------------------------------+
//| User function OpenRSIOverSoldLong().                                 |
//| Returns true when long opening conditions are met according to   |
//| EA rules                                                         |
//+------------------------------------------------------------------+
bool OpenRSIOverSoldLong()
{  
   return (
      rsi_1 > 30.0 && rsi_2 < 30.0
   );
}

bool CloseRSIOverSoldLong()
{
   return (
      rsi_1 < 30.0 || rsi_2 > 50.0
   );
}

//+------------------------------------------------------------------+
//| User function OpenRSIOverBoughtShort().                                |
//| Returns true when short opening conditions are met according to  |
//| EA rules                                                         |
//+------------------------------------------------------------------+
bool OpenRSIOverBoughtShort()
{
   return (
      rsi_1 < 70.0 && rsi_2 > 70.0
   );
}

bool CloseRSIOverBoughtShort()
{
   return (
      rsi_1 > 70.0 || rsi_2 < 50.0
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
//| User function IsOpen()                                           |
//| Returns true when a market order on this security is open        |
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
//| User function CalculateSL                                        |
//+------------------------------------------------------------------+
double CalculateSL(int magic)
{
   if (magic == USER_MAGIC_DAILY_LONG) {
      return USER_STOP_LOSS;
   } else if (magic == USER_MAGIC_DAILY_SHORT) {
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
   if (magic == USER_MAGIC_DAILY_LONG) {
      return USER_TAKE_PROFIT;
   } else if (magic == USER_MAGIC_DAILY_SHORT) {
      return USER_TAKE_PROFIT;
   } else {
      return USER_TAKE_PROFIT;
   }
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
               Open[0] - openPrice > MathAbs(takeProfit - openPrice) / 4 &&
               stopLoss < openPrice
            )
         {
            TrailStopLoss(ticketLong, NormalizeDouble(openPrice, Digits));
         }
         if (
               stopLoss <= openPrice &&
               Open[0] - openPrice > 2 * MathAbs(takeProfit - openPrice) / 3
            )
         {
            TrailStopLoss(ticketLong, NormalizeDouble(openPrice + MathAbs(takeProfit - openPrice)/3, Digits));
            MoveTakeProfit(ticketLong, NormalizeDouble(takeProfit + MathAbs(takeProfit - openPrice)/3, Digits));
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
               openPrice - Open[0] > MathAbs(takeProfit - openPrice) / 4 &&
               stopLoss > openPrice
            )
         {
            TrailStopLoss(ticketShort, NormalizeDouble(openPrice, Digits));
         }
         if (
               stopLoss >= openPrice &&
               openPrice - Open[0] > 2 * MathAbs(takeProfit - openPrice) / 3
            )
         {
            TrailStopLoss(ticketShort, NormalizeDouble(openPrice - MathAbs(takeProfit - openPrice)/3, Digits));
            MoveTakeProfit(ticketShort, NormalizeDouble(takeProfit - MathAbs(takeProfit - openPrice)/3, Digits));
         }
         i++;
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
         SL==0?0:Bid-SL,
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
         SL==0?0:Bid-SL, ", TP=", Bid+TP);
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
         SL==0?0:Ask+SL,
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
         SL==0?0:Ask+SL, ", TP=", Ask-TP);
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