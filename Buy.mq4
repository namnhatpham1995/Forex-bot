#property copyright "Pham Nhat Nam 2018"
#property strict
extern double               Lots = 0.01; // so lots
extern int               TP = 100; // Take Profit
extern int               SL = 100; // Stop Loss
extern double               Multiply = 2; // He so nhan lots
double buylimitlot, buylimitTP, buylimitSL, buylimitPrice;
double spread;
int count;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
         spread = MarketInfo(Symbol(),MODE_SPREAD);
         double minlot = MarketInfo(Symbol(),MODE_MINLOT);
         double maxlot = MarketInfo(Symbol(),MODE_MAXLOT);
         double step = MarketInfo(Symbol(),MODE_LOTSTEP);
         double margin = MarketInfo(Symbol(),MODE_MARGINREQUIRED);
         
         Comment("Spread of "+ Symbol() + " is " + DoubleToStr(spread,0) +
         "\nMaximum lot can be traded is " + DoubleToStr(maxlot,2) +
         "\nMinimum lot can be traded is " + DoubleToStr(minlot,2) +
         "\nMargin required to trade 0.01 lot is " + DoubleToStr(margin/100,2) +
         "\nLeverage is: 1:" + DoubleToStr(AccountLeverage(),0));  
      //---
         return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(DayOfWeek()!=0 && DayOfWeek()!=6) //No trade on weekends
      {
            if(OpenOrders()==0)//If no order open
               {
                     //Check Latest order of History
                     for(count=1;count<OrdersHistoryTotal();count++)
                     {
                              OrderSelect(OrdersHistoryTotal()-count,SELECT_BY_POS,MODE_HISTORY);
                              if(OrderSymbol()==Symbol()) break; //Find last order with the same currency
                              
                     }
                     if((OrderType()==OP_BUY)&&(OrderProfit()<0)) //Last order is a loss
                       {
                              begintrade(OrderLots()*Multiply,TP,SL,Multiply);
                       }
                     else //Last order is a profit or a buylimit
                       {
                              begintrade(Lots,TP,SL,Multiply);
                       }
               }
            else if(OpenOrders()==1)//If there is lot open
              {
                     OrderSelect(OrdersTotal()-1,SELECT_BY_POS,MODE_TRADES);
                     if (OrderType()==OP_BUYLIMIT)
                     {
                              OrderDelete(OrderTicket(),clrNONE);
                     }
                     else if(OrderType()==OP_BUY)
                     {
                              buylimitlot=OrderLots()*Multiply;
                              buylimitPrice=NormalizeDouble(OrderStopLoss()+ spread*Point,Digits);
                              buylimitSL=NormalizeDouble(OrderStopLoss()+ (spread-SL)*Point,Digits);
                              buylimitTP=NormalizeDouble(OrderStopLoss()+ (spread+TP)*Point,Digits);
                              OrderSend(Symbol(),OP_BUYLIMIT,buylimitlot,buylimitPrice,0,buylimitSL,buylimitTP,NULL,111,0,clrBlueViolet);
                     }
              }
      }
  }
//+------------------------------------------------------------------+



/////////////////////////////////////////////
//Begin Trade function///////////////////////
/////////////////////////////////////////////
void begintrade(double optlot, int TP, int SL,double Multiply)
{
            OrderSend(Symbol(),OP_BUY,optlot,Ask,0,NormalizeDouble(Ask-SL*Point,Digits),NormalizeDouble(Ask+TP*Point,Digits),NULL,111,0,clrBlue);   //Open buy order with SL=200, TP=100
            OrderSelect(OrdersTotal()-1,SELECT_BY_POS);                                   //Select buy order through its position (0)
            int buyticket=OrderTicket();                                                      //Get the ticket of buy order
            
            //Open Buy Limit
            buylimitlot=optlot*Multiply;
            OrderSelect(buyticket,SELECT_BY_TICKET);   //Select the buy order through ticket
            buylimitPrice=NormalizeDouble(OrderStopLoss()+ spread*Point,Digits);
            buylimitSL=NormalizeDouble(OrderStopLoss()+ (spread-SL)*Point,Digits);
            buylimitTP=NormalizeDouble(OrderStopLoss()+ (spread+TP)*Point,Digits);
                                               
            OrderSend(Symbol(),OP_BUYLIMIT,buylimitlot,buylimitPrice,0,buylimitSL,buylimitTP,NULL,111,0,clrBlueViolet);
            //OrderSelect(OrdersTotal()-1,SELECT_BY_POS);
            //buylimitticket=OrderTicket(); 
            //timescheck1=1; 
                     
}

///////////////////////////////////////
//CHECK OPEN ORDER OF EACH MONEY///////
//////////////////////////////////////
int OpenOrders()
{
   int orders=0; 
   for (int i=0; i<OrdersTotal(); i++)
   { 
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) 
      if(OrderSymbol()==Symbol()) 
      orders++; 
   }  
   return(orders); 
}