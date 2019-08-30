
#property copyright "Pham Nhat Nam"
#property strict
input double               Lots = 0.01; // so lots
input int               TP = 100; // Take Profit
input int               SL = 100; // Stop Loss
input double               Multiply = 2; // He so nhan lots
extern int                 BeginNew=2;//Bat dau lai trade tu dau (0 la chay tiep history, 1 la chay tu dau 0.01 lot)
input int               Pluspoint=200; //He so cong them cho open price tai 0h
extern int              ChartUse=2;//Chon chart de trade/test: 1 la H1, 2 la D1;
double buylimitlot, buylimitTP, buylimitSL, buylimitPrice;
double selllimitlot, selllimitTP, selllimitSL, selllimitPrice;
double spread;
int selldeleteticket, buydeleteticket;
int count;
double margin;
double openprice;
datetime timeopenprice;
////////////////////////////////////////////////////////////////////////
double optlot=Lots;
int checkBeginNew=BeginNew;
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
            if (BeginNew==0 || BeginNew==1)
            {
                     if(DayOfWeek()!=0 && DayOfWeek()!=6 && Hour()>=0 && Hour()<=22 && OpenOrders()==0) //No trade on weekends, Midnight and when there is order opening
                        {
                                    if((OrdersHistoryTotal()!=1)&& (BeginNew==0))
                                    { 
                                           for(count=1;count<OrdersHistoryTotal();count++)
                                          {
                                                   OrderSelect(OrdersHistoryTotal()-count,SELECT_BY_POS,MODE_HISTORY);
                                                   if(OrderSymbol()==Symbol()) break; //Find last order with the same currency
                                                   
                                          }
                                           if (TimeToStr(OrderCloseTime(),TIME_DATE)!=TimeToStr(TimeCurrent(),TIME_DATE))
                                           {
                                                      if(OrderProfit()<0)  //Last order is a loss
                                                      {
                                                            //double openprice=iOpen(Symbol(),PERIOD_H1,0);
                                                            if (TimeToStr(timeopenprice,TIME_DATE)==TimeToStr(TimeCurrent(),TIME_DATE))
                                                            {
                                                                     if (Bid==NormalizeDouble(openprice+Pluspoint*Point,Digits))
                                                                     {
                                                                              margin = MarketInfo(Symbol(),MODE_MARGINREQUIRED);
                                                                              if ((NormalizeDouble(OrderLots()*Multiply,2))*margin<AccountEquity())
                                                                              {
                                                                                    beginbuy(NormalizeDouble(OrderLots()*Multiply,2),TP,SL);
                                                                                    BeginNew=2;
                                                                              }
                                                                              else 
                                                                              {
                                                                                    beginbuy(Lots,TP,SL);
                                                                                    BeginNew=2;
                                                                              }
                                                                     }
                                                                     else if (Bid==NormalizeDouble(openprice-Pluspoint*Point,Digits))
                                                                     {
                                                                              margin = MarketInfo(Symbol(),MODE_MARGINREQUIRED);
                                                                              if ((NormalizeDouble(OrderLots()*Multiply,2))*margin<AccountEquity())
                                                                              {
                                                                                    beginsell(NormalizeDouble(OrderLots()*Multiply,2),TP,SL);
                                                                                    BeginNew=2;
                                                                              }
                                                                              else 
                                                                              {
                                                                                    beginsell(optlot,TP,SL);
                                                                                    BeginNew=2;
                                                                              }
                                                                     }
                                                              }
                                                              else
                                                              {
                                                                  BeginNew=2;
                                                              }
                                                            
                                                      }
                                                      else
                                                      {
                                                            if (TimeToStr(timeopenprice,TIME_DATE)==TimeToStr(TimeCurrent(),TIME_DATE))
                                                            {
                                                                     if (Bid==NormalizeDouble(openprice+Pluspoint*Point,Digits))
                                                                     {
                                                                              beginbuy(Lots, TP, SL);
                                                                              BeginNew=2;
                                                                     }
                                                                     else if (Bid==NormalizeDouble(openprice-Pluspoint*Point,Digits))
                                                                     {
                                                                              beginsell(Lots, TP, SL);
                                                                              BeginNew=2;
                                                                     }
                                                             }
                                                             else
                                                              {
                                                                  BeginNew=2;
                                                              }
                                                            
                                                      }
                                                      
                                           }  
                                    }
                                    else
                                    {
                                             if (TimeToStr(timeopenprice,TIME_DATE)==TimeToStr(TimeCurrent(),TIME_DATE))
                                             {
                                                         if (Bid==NormalizeDouble(openprice+Pluspoint*Point,Digits))
                                                         {
                                                                  beginbuy(Lots, TP, SL);
                                                                  BeginNew=2;
                                                         }
                                                         else if (Bid==NormalizeDouble(openprice-Pluspoint*Point,Digits))
                                                         {
                                                                  beginsell(Lots, TP, SL);
                                                                  BeginNew=2;
                                                         }
                                             }
                                              else
                                            {
                                                BeginNew=2;
                                            }
                                    }
                                  
                                
                      }
            }
            else
           {
                     if (Hour()==0)
                     {
                           BeginNew=0;
                           if(ChartUse=2)
                           {
                              openprice=iOpen(Symbol(),PERIOD_D1,0);
                           }
                           else
                          {
                           openprice=iOpen(Symbol(),PERIOD_H1,0);
                          }
                          timeopenprice=TimeCurrent();
                          
                     }
                     
           }
  }
//+------------------------------------------------------------------+



/////////////////////////////////////////////
//Begin Trade function///////////////////////
/////////////////////////////////////////////
void beginbuy(double optlot, int TP, int SL)
{
            OrderSend(Symbol(),OP_BUY,optlot,Ask,0,NormalizeDouble(Ask-SL*Point,Digits),NormalizeDouble(Ask+TP*Point,Digits),NULL,111,0,clrBlue);   //Open buy order with SL=200, TP=100
            OrderSelect(OrdersTotal()-1,SELECT_BY_POS);                                   //Select buy order through its position (0)
            
            
          
}
/////////////////////////////////////////////
//Begin Trade function///////////////////////
/////////////////////////////////////////////
void beginsell(double optlot, int TP, int SL)
{           
            OrderSend(Symbol(),OP_SELL,optlot,Bid,0,NormalizeDouble(Bid+SL*Point,Digits),NormalizeDouble(Bid-TP*Point,Digits),NULL,112,0,clrRed);  //Open sell order with SL=200, TP=100
            OrderSelect(OrdersTotal()-1,SELECT_BY_POS);                                   //Select sell order through its position (1)

}

///////////////////////////////////////
//CHECK BUY ORDER OF EACH MONEY///////
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
