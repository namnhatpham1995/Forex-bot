
#property copyright "Pham Nhat Nam"
#property strict
extern double               Lots = 0.01; // so lots
extern int               TP = 100; // Take Profit
extern int               SL = 100; // Stop Loss
extern double               Multiply = 2; // He so nhan lots
double buylimitlot, buylimitTP, buylimitSL, buylimitPrice;
double selllimitlot, selllimitTP, selllimitSL, selllimitPrice;
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
            if(BuyOrders()==0)//If no order open
               {
                     //Check Latest order of History
                     for(count=1;count<OrdersHistoryTotal();count++)
                     {
                              OrderSelect(OrdersHistoryTotal()-count,SELECT_BY_POS,MODE_HISTORY);
                              if(OrderSymbol()==Symbol()) break; //Find last order with the same currency
                              
                     }
                     if((OrderType()==OP_BUY)&&(OrderProfit()<0)) //Last order is a loss
                       {
                              beginbuy(NormalizeDouble(OrderLots()*Multiply,2),TP,SL,Multiply);
                       }
                     else //Last order is a profit or a buylimit
                       {
                              beginbuy(Lots,TP,SL,Multiply);
                       }
               }
            else if(BuyOrders()==1)//If there is a buy order open
              {
                     for(count=1;count<OrdersTotal();count++)
                     {
                           OrderSelect(OrdersTotal()-count,SELECT_BY_POS,MODE_TRADES);
                           if (OrderType()==OP_BUYLIMIT)
                           {
                                    OrderDelete(OrderTicket(),clrNONE);
                                    break;
                           }
                           else if(OrderType()==OP_BUY)
                           {
                                    buylimitlot=NormalizeDouble(OrderLots()*Multiply,2);
                                    spread = MarketInfo(Symbol(),MODE_SPREAD);
                                    buylimitPrice=NormalizeDouble(OrderStopLoss()+ spread*Point,Digits);
                                    buylimitSL=NormalizeDouble(OrderStopLoss()+ (spread-SL)*Point,Digits);
                                    buylimitTP=NormalizeDouble(OrderStopLoss()+ (spread+TP)*Point,Digits);
                                    OrderSend(Symbol(),OP_BUYLIMIT,buylimitlot,buylimitPrice,0,buylimitSL,buylimitTP,NULL,111,0,clrBlueViolet);
                                    break;
                           }
                      }
              }
            RefreshRates();  
            if(SellOrders()==0)//If no order open
               {
                     //Check Latest order of History
                     for(count=1;count<OrdersHistoryTotal();count++)
                     {
                              OrderSelect(OrdersHistoryTotal()-count,SELECT_BY_POS,MODE_HISTORY);
                              if(OrderSymbol()==Symbol()) break; //Find last order with the same currency
                              
                     }
                     if((OrderType()==OP_SELL)&&(OrderProfit()<0)) //Last order is a loss
                       {
                              beginsell(NormalizeDouble(OrderLots()*Multiply,2),TP,SL,Multiply);
                       }
                     else //Last order is a profit or a buylimit
                       {
                              beginsell(Lots,TP,SL,Multiply);
                       }
               }
            else if(SellOrders()==1)//If there is lot open
              {
                     for(count=1;count<OrdersTotal();count++)
                     {
                           OrderSelect(OrdersTotal()-count,SELECT_BY_POS,MODE_TRADES);
                           if (OrderType()==OP_SELLLIMIT)
                           {
                                    OrderDelete(OrderTicket(),clrNONE);
                                    break;
                           }
                           else if(OrderType()==OP_SELL)
                           {
                                    //Open Sell Limit
                                    spread = MarketInfo(Symbol(),MODE_SPREAD);
                                    selllimitlot=NormalizeDouble(OrderLots()*Multiply,2);
                                    selllimitPrice=NormalizeDouble(OrderStopLoss()- spread*Point,Digits);
                                    selllimitSL=NormalizeDouble(OrderStopLoss()+ (-spread+SL)*Point,Digits);
                                    selllimitTP=NormalizeDouble(OrderStopLoss()+ (-spread-TP)*Point,Digits);
                                    OrderSend(Symbol(),OP_SELLLIMIT,selllimitlot,selllimitPrice,0,selllimitSL,selllimitTP,NULL,112,0,clrRosyBrown);
                                    break;
                           }
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
            int buyticket=OrderTicket();                                                      //Get the ticket of buy order

            //Open Buy Limit
            buylimitlot=NormalizeDouble(optlot*Multiply,2);
            OrderSelect(buyticket,SELECT_BY_TICKET);   //Select the buy order through ticket
            buylimitPrice=NormalizeDouble(OrderStopLoss()+ spread*Point,Digits);
            buylimitSL=NormalizeDouble(OrderStopLoss()+ (spread-SL)*Point,Digits);
            buylimitTP=NormalizeDouble(OrderStopLoss()+ (spread+TP)*Point,Digits);
                                               
            OrderSend(Symbol(),OP_BUYLIMIT,buylimitlot,buylimitPrice,0,buylimitSL,buylimitTP,NULL,111,0,clrBlueViolet);
            //OrderSelect(OrdersTotal()-1,SELECT_BY_POS);
            //buylimitticket=OrderTicket(); 
            //timescheck1=1; 
            
          
}
/////////////////////////////////////////////
//Begin Trade function///////////////////////
/////////////////////////////////////////////
void beginsell(double optlot, int TP, int SL, double Multiply)
{           
            OrderSend(Symbol(),OP_SELL,optlot,Bid,0,NormalizeDouble(Bid+SL*Point,Digits),NormalizeDouble(Bid-TP*Point,Digits),NULL,112,0,clrRed);  //Open sell order with SL=200, TP=100
            OrderSelect(OrdersTotal()-1,SELECT_BY_POS);                                   //Select sell order through its position (1)
            int sellticket=OrderTicket();                                                     //Get the ticket of sell order
             
            
            //Open Sell Limit
            selllimitlot=NormalizeDouble(optlot*Multiply,2);
            OrderSelect(sellticket,SELECT_BY_TICKET);                                      //Select the sell order through ticket
            selllimitPrice=NormalizeDouble(OrderStopLoss()- spread*Point,Digits);
            selllimitSL=NormalizeDouble(OrderStopLoss()+ (-spread+SL)*Point,Digits);
            selllimitTP=NormalizeDouble(OrderStopLoss()+ (-spread-TP)*Point,Digits);
            
            OrderSend(Symbol(),OP_SELLLIMIT,selllimitlot,selllimitPrice,0,selllimitSL,selllimitTP,NULL,112,0,clrRosyBrown);
            //OrderSelect(OrdersTotal()-1,SELECT_BY_POS);
            //selllimitticket=OrderTicket();
            //timescheck2=1;
}

///////////////////////////////////////
//CHECK BUY ORDER OF EACH MONEY///////
//////////////////////////////////////
int BuyOrders()
{
   int buyorders=0; 
   for (int i=0; i<OrdersTotal(); i++)
   { 
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      { 
            if((OrderSymbol()==Symbol())&& ((OrderType()==OP_BUY)||(OrderType()==OP_BUYLIMIT))) buyorders++;
      } 
   }  
   return(buyorders); 
}
///////////////////////////////////////
//CHECK SELL ORDER OF EACH MONEY///////
//////////////////////////////////////
int SellOrders()
{
   int sellorders=0; 
   for (int i=0; i<OrdersTotal(); i++)
   { 
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) 
      {
            if((OrderSymbol()==Symbol())&& ((OrderType()==OP_SELL)||(OrderType()==OP_SELLLIMIT))) sellorders++;
      } 
   }  
   return(sellorders); 
}