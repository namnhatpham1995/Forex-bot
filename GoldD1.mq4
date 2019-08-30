
#property copyright "Pham Nhat Nam"
#property strict
input double               Lots = 0.01; // so lots
input int               TP = 400; // Take Profit
input double               Multiply = 2; // He so nhan lots
extern int                 BeginNew=2;//Bat dau lai trade tu dau (0 la chay tiep history, 1 la chay tu dau 0.01 lot)
double buylimitlot, buylimitTP, buylimitSL, buylimitPrice;
double selllimitlot, selllimitTP, selllimitSL, selllimitPrice;
double spread;
int selldeleteticket, buydeleteticket;
int count;
double margin;
double LowCheck, HighCheck;
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
         if(DayOfWeek()!=0 && DayOfWeek()!=6 && Hour()>=0 && Hour()<=22) //No trade on weekends, Midnight and when there is order opening
         {
                  if(PendingOrders()==0 && TradingOrders()==0)
                  {
                           if(condition)
                             {
                                       spread = MarketInfo(Symbol(),MODE_SPREAD);
                                       LowCheck=NormalizeDouble((iLow(Symbol(),PERIOD_D1,1)-spread*2*Point,Digits);
                                       HighCheck=NormalizeDouble((iHigh(Symbol(),PERIOD_D1,1))+spread*3*Point,Digits);
                                       if (Ask<HighCheck && Ask > LowCheck && Bid<HighCheck && Bid > LowCheck)
                                       { 
                                             beginbuy(Lots,TP,HighCheck,LowCheck);
                                             beginsell(Lots,TP,LowCheck,HighCheck);
                                       }
                             }
                           
                  }
                  else if(PendingOrders()==1 && TradingOrders()==1)
                  {
                             if(buyOrders()==1 && sellstopOrders()==1)
                             {
                                       for (int i=0; i<OrdersTotal(); i++)
                                       { 
                                                OrderSelect(i, SELECT_BY_POS, MODE_TRADES));
                                                if ((OrderSymbol()==Symbol())&&(OrderType()==OP_SELLSTOP)) 
                                                {
                                                         
                                                         OrderDelete(OrderTicket(),clrNONE);
                                                         spread = MarketInfo(Symbol(),MODE_SPREAD);
                                                         LowCheck=NormalizeDouble(iLow(Symbol(),PERIOD_D1,1)-spread*2*Point,Digits);
                                                         HighCheck=NormalizeDouble((iHigh(Symbol(),PERIOD_D1,1))+spread*3*Point,Digits);
                                                         optlot=(((HighCheck-LowCheck)/Point)/TP)+2;
                                                         beginsell(optlot,TP,LowCheck,HighCheck);
                                                }
                                               
                                       }
                             }
                             else if(sellOrders()==1 && buystopOrders()==1)
                             {
                                       for (int i=0; i<OrdersTotal(); i++)
                                       { 
                                                OrderSelect(i, SELECT_BY_POS, MODE_TRADES));
                                                if ((OrderSymbol()==Symbol())&&(OrderType()==OP_BUYSTOP)) 
                                                {
                                                         
                                                         OrderDelete(OrderTicket(),clrNONE);
                                                         spread = MarketInfo(Symbol(),MODE_SPREAD);
                                                         LowCheck=NormalizeDouble(iLow(Symbol(),PERIOD_D1,1)-spread*2*Point,Digits);
                                                         HighCheck=NormalizeDouble((iHigh(Symbol(),PERIOD_D1,1))+spread*3*Point,Digits);
                                                         optlot=(((HighCheck-LowCheck)/Point)/TP)+2;
                                                         beginbuy(optlot,TP,HighCheck,LowCheck);
                                                }
                                               
                                       }
                             }
                  }
         }
         
  }
//+------------------------------------------------------------------+



/////////////////////////////////////////////
//Begin Trade function///////////////////////
/////////////////////////////////////////////
void beginbuy(double optlot, int TP, double OpenPrice,double ClosePrice)
{
            OrderSend(Symbol(),OP_BUYSTOP,optlot,OpenPrice,0,ClosePrice,NormalizeDouble(OpenPrice+TP*Point,Digits),NULL,111,0,clrBlue);   //Open buy order with SL=200, TP=100
            OrderSelect(OrdersTotal()-1,SELECT_BY_POS);                                   //Select buy order through its position (0)
            
            
          
}
/////////////////////////////////////////////
//Begin Trade function///////////////////////
/////////////////////////////////////////////
void beginsell(double optlot, int TP, double OpenPrice,double ClosePrice)
{           
            OrderSend(Symbol(),OP_SELLSTOP,optlot,OpenPrice,0,ClosePrice,NormalizeDouble(OpenPrice-TP*Point,Digits),NULL,112,0,clrRed);  //Open sell order with SL=200, TP=100
            OrderSelect(OrdersTotal()-1,SELECT_BY_POS);                                   //Select sell order through its position (1)

}

///////////////////////////////////////
//CHECK PENDING ORDER OF EACH MONEY///////
//////////////////////////////////////
int PendingOrders()
{
   int pendingorders=0; 
   for (int i=0; i<OrdersTotal(); i++)
   { 
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      { 
            if ((OrderSymbol()==Symbol())&&((OrderType()==OP_BUYSTOP)||(OrderType()==OP_SELLSTOP))) pendingorders++;
      } 
   }  
   return(pendingorders); 
}
///////////////////////////////////////
//CHECK TRADING ORDER OF EACH MONEY///////
//////////////////////////////////////
int TradingOrders()
{
   int tradingorders=0; 
   for (int i=0; i<OrdersTotal(); i++)
   { 
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      { 
            if ((OrderSymbol()==Symbol())&&((OrderType()==OP_BUY)||(OrderType()==OP_SELL))) tradingorders++;
      } 
   }  
   return(tradingorders); 
}

///////////////////////////////////////
//CHECK BUYSTOP ORDER OF EACH MONEY///////
//////////////////////////////////////
int buystopOrders()
{
   int buystoporder=0; 
   for (int i=0; i<OrdersTotal(); i++)
   { 
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      { 
            if ((OrderSymbol()==Symbol())&&(OrderType()==OP_BUYSTOP)) buystoporder++;
      } 
   }  
   return(buystoporder); 
}
///////////////////////////////////////
//CHECK SELLSTOP ORDER OF EACH MONEY///////
//////////////////////////////////////
int sellstopOrders()
{
   int sellstoporder=0; 
   for (int i=0; i<OrdersTotal(); i++)
   { 
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      { 
            if ((OrderSymbol()==Symbol())&&(OrderType()==OP_SELLSTOP)) sellstoporder++;
      } 
   }  
   return(sellstoporder); 
}
///////////////////////////////////////
//CHECK SELL ORDER OF EACH MONEY///////
//////////////////////////////////////
int sellOrders()
{
   int sellorder=0; 
   for (int i=0; i<OrdersTotal(); i++)
   { 
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      { 
            if ((OrderSymbol()==Symbol())&&(OrderType()==OP_SELLSTOP)) sellorder++;
      } 
   }  
   return(sellorder); 
}
///////////////////////////////////////
//CHECK BUY ORDER OF EACH MONEY///////
//////////////////////////////////////
int buyOrders()
{
   int buyorder=0; 
   for (int i=0; i<OrdersTotal(); i++)
   { 
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      { 
            if ((OrderSymbol()==Symbol())&&(OrderType()==OP_SELLSTOP)) buyorder++;
      } 
   }  
   return(buyorder); 
}