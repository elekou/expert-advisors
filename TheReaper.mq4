//+------------------------------------------------------------------+
//|                                                    TheReaper.mq4 |
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
extern bool USER_LOGGER_DEBUG=false;                                 // Enable or disable debug log
extern double USER_MINIMUM_REAP_PERCENTAGE=0.10;                     // Minimum reap profit
extern double USER_MAXIMUM_REAP_PERCENTAGE=0.15;                     // Maximum reap profit
bool minimumReapPercentageAchieved = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{  
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

   double profit = GetProfit();
   double reapPercentage = NormalizeDouble(GetProfit() / AccountBalance(), 4);

   if (reapPercentage > USER_MINIMUM_REAP_PERCENTAGE)
   {
      minimumReapPercentageAchieved = true;
   }
   if (reapPercentage > USER_MAXIMUM_REAP_PERCENTAGE) {
      minimumReapPercentageAchieved = false;
      Alert("Reaping ", profit, " profit at ", reapPercentage, " reap percentage");
      SendNotification("Reaping " + DoubleToString(profit)
         + " profit at " + DoubleToString(reapPercentage) + " reap percentage");
      CloseAll();
   }
   if (minimumReapPercentageAchieved && reapPercentage < (USER_MINIMUM_REAP_PERCENTAGE - 0.01)) {
      minimumReapPercentageAchieved = false;
      Alert("Reaping ", profit, " profit at ", reapPercentage, " reap percentage");
      SendNotification("Reaping " + DoubleToString(profit)
         + " profit at " + DoubleToString(reapPercentage) + " reap percentage");
      CloseAll();
   }
}

//+------------------------------------------------------------------+
//| User function Log()                                              |
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
//| User function GetProfit()                                        |
//| Calculate profit of open trades.                                 |
//+------------------------------------------------------------------+
double GetProfit()
{
   double profit = 0.0;
   for (int i=1; i<=OrdersTotal(); i++)
   {
      if (OrderSelect(i-1, SELECT_BY_POS)==true)
      {
         profit += (OrderProfit()+OrderSwap());
      }
   }
   return profit;
}

//+------------------------------------------------------------------+
//| User function CloseAll()                                         |
//| Closes all open trades, short and long                           |
//+------------------------------------------------------------------+
void CloseAll()
{
      while (OrderSelect(0, SELECT_BY_POS)==true)
      {
         Print("CloseAll: Closing order #", OrderTicket());
         if (OrderType()==OP_BUY)
         {
            CloseLong(OrderTicket(), OrderLots());
         }
         else if (OrderType()==OP_SELL)
         {
            CloseShort(OrderTicket(), OrderLots());
         }
         else
         {
            Print("CloseAll: Skipping order #", OrderTicket(), " with Order Type ", OrderType());
            continue;
         }
      }
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

