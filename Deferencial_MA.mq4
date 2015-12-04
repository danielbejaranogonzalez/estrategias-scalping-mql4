//+------------------------------------------------------------------+
//|                                               Deferencial_MA.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

string tiempo;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(1);
      
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   mostrarTiempo();
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
     
  }
//+------------------------------------------------------------------+

void mostrarTiempo(){
   
   string mes, hora, minutos, segundos;
   if(Hour() < 9)
      hora = "0"+Hour();
   else
      hora = Hour();
   
   if(Minute() < 9)
      minutos = "0"+Minute();
   else
      minutos = Minute();
   
   if(Seconds() < 9)
      segundos = "0"+Seconds();
   else
      segundos = Seconds();
   
   tiempo = Day()+"/"+Month()+" - "+hora+":"+minutos+":"+segundos;
   imprimirTiempo(tiempo, White);
}

void imprimirTiempo(string time, color colorActual){
    ObjectDelete("TIME");
    ObjectCreate("TIME", OBJ_LABEL, 0, 0, 0);
    ObjectSet("TIME", OBJPROP_CORNER, 1);
    ObjectSet("TIME", OBJPROP_XDISTANCE,10);
    ObjectSet("TIME", OBJPROP_YDISTANCE,10);
    ObjectSetText("TIME", "[GMT+2]: " +  time, 13, "Arial", colorActual);
}