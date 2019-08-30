
#property copyright "Pham Nhat Nam"
#property strict
extern double               Lots = 0.01; // so lots
extern int               TP = 100; // Take Profit
extern int               SL = 100; // Stop Loss
extern double               Multiply = 2; // He so nhan lots
extern int                 BeginNew=0;//Bat dau lai buy tu dau (0 la chay tiep history, 1 la chay tu dau 0.01 lot)
double buylimitlot, buylimitTP, buylimitSL, buylimitPrice;
double selllimitlot, selllimitTP, selllimitSL, selllimitPrice;
double spread;
int selldeleteticket, buydeleteticket;
int count;
double margin;
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
   margin = MarketInfo(Symbol(),MODE_MARGINREQUIRED);
   
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
   if(DayOfWeek()!=0 && DayOfWeek()!=6 && Hour()!=23 && Hour()!=0) //No trade on weekends and Midnight
      {
            if(OpenOrders()==0)//If no order open
               {
                     //Check Latest order of History
                     if(OrdersHistoryTotal()!=1)
                     {  
                                 if(BeginNew==0)
                                 {
                                          for(count=1;count<OrdersHistoryTotal();count++)
                                          {
                                                   OrderSelect(OrdersHistoryTotal()-count,SELECT_BY_POS,MODE_HISTORY);
                                                   if(OrderSymbol()==Symbol()) break; //Find last order with the same currency
                                                   
                                          }
                                          if(OrderProfit()<0) //Last order is a loss
                                            {      
                                                   if (OrderType()==OP_SELL)
                                                   {
                                                         margin = MarketInfo(Symbol(),MODE_MARGINREQUIRED);
                                                         if ((NormalizeDouble(OrderLots()*Multiply,2))*margin<AccountEquity())
                                                         {
                                                               beginbuy(NormalizeDouble(OrderLots()*Multiply,2),TP,SL,Multiply);
                                                         }
                                                         else beginbuy(Lots,TP,SL,Multiply);
                                                   }
                                                   else if (OrderType()==OP_BUY)
                                                   {
                                                         margin = MarketInfo(Symbol(),MODE_MARGINREQUIRED);
                                                         if ((NormalizeDouble(OrderLots()*Multiply,2))*margin<AccountEquity())
                                                         {
                                                               beginsell(NormalizeDouble(OrderLots()*Multiply,2),TP,SL,Multiply);
                                                         }
                                                         else beginsell(Lots,TP,SL,Multiply);
                                                   }
                                            }
                                          else //Last order is a profit or a buylimit
                                            {
                                                   beginbuy(Lots,TP,SL,Multiply);
                                            }
                                  }
                                  else
                                  {
                                       beginbuy(Lots,TP,SL,Multiply);
                                       BeginNew=0;
                                  }
                      }
                      else 
                      {
                           beginbuy(Lots,TP,SL,Multiply);
                           
                      }
               }
           
 
            
              
      }
  }
//+------------------------------------------------------------------+



/////////////////////////////////////////////
//Begin Trade function///////////////////////
/////////////////////////////////////////////
void beginbuy(double optlot, int TP, int SL, double Multiply)
{
            OrderSend(Symbol(),OP_BUY,optlot,Ask,0,NormalizeDouble(Ask-SL*Point,Digits),NormalizeDouble(Ask+TP*Point,Digits),NULL,111,0,clrBlue);   //Open buy order with SL=200, TP=100
            OrderSelect(OrdersTotal()-1,SELECT_BY_POS);                                   //Select buy order through its position (0)
            
            
          
}
/////////////////////////////////////////////
//Begin Trade function///////////////////////
/////////////////////////////////////////////
void beginsell(double optlot, int TP, int SL, double Multiply)
{           
            OrderSend(Symbol(),OP_SELL,optlot,Bid,0,NormalizeDouble(Bid+SL*Point,Digits),NormalizeDouble(Bid-TP*Point,Digits),NULL,112,0,clrRed);  //Open sell order with SL=200, TP=100
            OrderSelect(OrdersTotal()-1,SELECT_BY_POS);                                   //Select sell order through its position (1)

}


///////////////////////////////////////
//CHECK ORDER OF EACH MONEY///////
//////////////////////////////////////
int OpenOrders()
{
   int orders=0; 
   for (int i=0; i<OrdersTotal(); i++)
   { 
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      { 
            if (OrderSymbol()==Symbol()) orders++;
      } 
   }  
   return(orders); 
}