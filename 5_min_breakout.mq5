//+------------------------------------------------------------------+
//|                                               5_min_breakout.mq5 |
//|                                                    Fardin Marabi |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Fardin Marabi"
#property link      "https://www.mql5.com"
#property version   "1.00"



// when high or low of last highTF candel is break in lower tf candel in recent HTF candel we enter a trader in direction of that break

#include<Trade/Trade.mqh>
CTrade trade;

CTrade                  m_trade;      
CPositionInfo           m_position; 



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
//Global Variables
static input ENUM_TIMEFRAMES lowerTF=PERIOD_M1;
static input ENUM_TIMEFRAMES higherTF=PERIOD_H4;


input group "ORDERS SETTINGS"
input double Volume=0.01;
input double Stop_Loss_Coeff=1;
input double Take_Profit_Coeff=0.5;
input int Hours_Expire=10;
input double riskPerTrade=1;
input double RR=1.3;
input double shadowToBodyRel=1;


double up_limit=0;
double down_limit=0;
double signal_controller=-1;


int barsTotal;


// ema 
double myEMA[];



int OnInit()
  {
//---
   barsTotal=iBars(NULL,lowerTF);
   
   
   
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
   int bars=iBars(NULL,lowerTF);
   
   
   if (barsTotal !=bars){
      
      barsTotal=bars;
  
      int signal=Spotting_Patterns(lowerTF,higherTF);
      double spread=SymbolInfoDouble(_Symbol,SYMBOL_ASK)-SymbolInfoDouble(_Symbol,SYMBOL_BID);
      
      if (signal==0){ // no signal so doing nothing
         return;
      }
      
      if((signal==1) && (signal_controller!=up_limit)){  //Buying order
         
         signal_controller=up_limit;
   
         double entry=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
         double sl=NormalizeDouble(((up_limit-down_limit)/2)+down_limit,_Digits); // update shavad
         
         double distanceEntryFromSL=entry-sl;
         double tp=NormalizeDouble(entry+(RR*distanceEntryFromSL),_Digits); // RR*sl distance
         
         double stoplossPoint=distanceEntryFromSL*MathPow(10,_Digits); //?? is *mathpow correct?
         double lotSize=volume_calculator(stoplossPoint);
         //Print("Entry is ",entry);
         //Print("sl is ",sl);
         //Print("distanceEntryFromSL is ",distanceEntryFromSL);
         //Print("tp is ",tp);
         
         trade.Buy(lotSize,NULL,entry,sl,tp);
         
      }
      if((signal==2) && (signal_controller!=up_limit)){  //Buying order
         
         signal_controller=up_limit;
         
         double entry=SymbolInfoDouble(_Symbol,SYMBOL_BID);
         double sl=NormalizeDouble(up_limit-((up_limit-down_limit)/2),_Digits);
         
         double distanceEntryFromSL=sl-entry;
         double tp=NormalizeDouble(entry-(RR*distanceEntryFromSL),_Digits); // 2*sl distance
         
         double stoplossPoint=distanceEntryFromSL*MathPow(10,_Digits);
         double lotSize=volume_calculator(stoplossPoint);
         
         trade.Sell(lotSize,NULL,entry,sl,tp); 
      }
      //close_reverse_trade(signal);
      
   }
   
  }
//+------------------------------------------------------------------+
int Spotting_Patterns(ENUM_TIMEFRAMES LTF,ENUM_TIMEFRAMES HTF){

   double last_HTF_high=iHigh(NULL,HTF,1);//last HTF candel
   double last_HTF_low=iLow(NULL,HTF,1);
   
   double last_HTF_open=iOpen(NULL,HTF,1);
   double last_HTF_close=iClose(NULL,HTF,1);
   
   double last_LTF_high=iHigh(NULL,LTF,1);//last LTF candel
   double last_LTF_low=iLow(NULL,LTF,1);
   
   double last_LTF_open=iOpen(NULL,LTF,1);
   double last_LTF_close=iClose(NULL,LTF,1);
   
   up_limit=last_HTF_high;
   down_limit=last_HTF_low;
   
   if (last_HTF_close>last_HTF_open){ // last HTF candel is bullish
      if (last_LTF_close>last_HTF_high){
         return 1;
      }
   }else{
      if(last_LTF_close<last_HTF_low){
         return 2;
      }
   }
   
   return 0;
}


double volume_calculator(double stoploss)
{
   if(stoploss==0){
     return(0);
   }
   
   double usd_risk = riskPerTrade*0.01 * AccountInfoDouble(ACCOUNT_BALANCE); 
   double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double profit=0; 
   bool check=OrderCalcProfit(ORDER_TYPE_BUY,_Symbol,1,ask,ask+100*_Point,profit); // ?? type buy
   double point_value = profit*0.01; //?? zero!
   double lotsize = usd_risk/(stoploss*point_value);
   int volume_digits=int(MathAbs(MathLog10(SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP))));    
   
   double final_lot=NormalizeDouble(lotsize,volume_digits);
   if (final_lot<=0.1){
      final_lot=0.1;
   }
   return final_lot;
  
}