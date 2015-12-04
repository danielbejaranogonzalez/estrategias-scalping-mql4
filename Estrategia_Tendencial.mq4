//+------------------------------------------------------------------+
//|                                        Estrategia_Tendencial.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

double cci34_current, cci46_current, macd_current;
string tiempo;

color color_cci34 = White, color_cci46 = White, color_macd = White;

int ticketNumberActual;

int flag_buy[3]={0,0,0};
int flag_sell[3]={0,0,0};

double UMBRAL_MACD = 0.00029;
double STOP_LOSS = 11;
double TAKE_PROFIT = 8;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
     //EventSetTimer(1);
     //Print("Error GetLastError() = ", GetLastError() ) ;
     return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
      
  }
  
void OnTimer()
{

     

}
  
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
     mostrarTiempo();
     
     cci34_current=iCCI(NULL,1,34,PRICE_CLOSE,0);
     cci46_current=iCCI(NULL,1,46,PRICE_CLOSE,0);
     macd_current=iMACD(NULL,1,21,89,1,PRICE_CLOSE,MODE_MAIN,0);
     
     // Colores de los indicadores
     if(cci34_current < -50)
      color_cci34 = Red;
     else if(cci34_current >= -50 && cci34_current <= 0)
      color_cci34 = Orange;
     else if(cci34_current > 0 && cci34_current <= 50)
      color_cci34 = Yellow;
     else
      color_cci34 = Green;
     
     if(cci46_current < -50)
         color_cci46 = Red;
     else if(cci46_current >= -50 && cci46_current <= 0)
         color_cci46 = Orange;
     else if(cci46_current > 0 && cci46_current <= 50)
         color_cci46 = Yellow;
     else
         color_cci46  = Green;
     
     if(macd_current < -UMBRAL_MACD)
         color_macd = Red;
     else if(macd_current >= -UMBRAL_MACD && macd_current <= UMBRAL_MACD)
         color_macd = Orange;
     else
         color_macd = Green;
     
     //Algoritmo de compra y venta
     
     if(calcularPromedioCCI(34,0,1)>10){
      // Si los dos anteriores tick estaban con CCI34 por debajo de 0
      if(calcularPromedioCCI(34,2,3)<=10){
         flag_buy[0]=1;
         flag_sell[0]=0;
      }
     }else if(calcularPromedioCCI(34,0,1) < -10){
      // Si los dos anteriores tick estaban con CCI34 por encima de 0
      if(calcularPromedioCCI(34,2,3)>=-10){
         flag_sell[0]=1;
         flag_buy[0]=0;
      }
     }
     
     if(calcularPromedioCCI(46,0,1)>=10){
      // Si los dos anteriores tick estaban con CCI34 por debajo de 0
      if(calcularPromedioCCI(46,2,3)<=10){
         flag_buy[1]=1;
         flag_sell[1]=0;
      }
     }else if(calcularPromedioCCI(46,0,1) < -10){
      // Si los dos anteriores tick estaban con CCI34 por encima de 0
      if(calcularPromedioCCI(46,2,3) >=-10){
         flag_sell[1]=1;
         flag_buy[1]=0;
      }
     }
     
     
     if((flag_buy[0]==1) && (flag_buy[1]==1)){
      if(macd_current >= UMBRAL_MACD){
         flag_buy[2]=1;
         if(OrdersTotal() < 1)
            ticketNumberActual = OrderSend(Symbol(),OP_BUY,0.02,Ask,3,Ask-STOP_LOSS*Point,Ask+TAKE_PROFIT*Point,NULL,0,0,Green);
         
         flag_buy[0]=0; flag_buy[1]=0; flag_buy[2]=0;
      }else
         flag_buy[0]=0; flag_buy[1]=0;
     }
     if((flag_sell[0]==1) && (flag_sell[1]==1)){
      if(macd_current <= -UMBRAL_MACD){
         flag_sell[2]=1;
         if(OrdersTotal() < 1)
            ticketNumberActual = OrderSend(Symbol(),OP_SELL,0.02,Bid,3,Bid+STOP_LOSS*Point,Bid-TAKE_PROFIT*Point,NULL,0,0,Red);
            
         flag_sell[0]=0; flag_sell[1]=0; flag_sell[2]=0;
      }else
         flag_buy[0]=0; flag_buy[1]=0;
     }
     
     // Impresiones de Pantalla
     imprimirCCI34(cci34_current, color_cci34);
     imprimirCCI46(cci46_current, color_cci46);
     imprimirMACD(macd_current, color_macd);
     imprimirBid(Bid,Red);
     imprimirAsk(Ask,Green);
     imprimirFlags();
  }
  
double calcularPromedioCCI(int periodo, int i, int j){

   double CCI_promedio;
   double CCI_sumatoria;
   
   CCI_sumatoria = iCCI(NULL,1,periodo,PRICE_CLOSE,i)+iCCI(NULL,1,periodo,PRICE_CLOSE,j);
   CCI_promedio = CCI_sumatoria/2;
   
   return CCI_promedio;
}  
  
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

void imprimirBid(string bid, color colorActual){
    ObjectDelete("BID");
    ObjectCreate("BID", OBJ_LABEL, 0, 0, 0);
    ObjectSet("BID", OBJPROP_CORNER, 1);
    ObjectSet("BID", OBJPROP_XDISTANCE,10);
    ObjectSet("BID", OBJPROP_YDISTANCE,25);
    ObjectSetText("BID", "Precio Compra: " +  bid, 10, "Arial", colorActual);
}

void imprimirAsk(string ask, color colorActual){
    ObjectDelete("ASK");
    ObjectCreate("ASK", OBJ_LABEL, 0, 0, 0);
    ObjectSet("ASK", OBJPROP_CORNER, 1);
    ObjectSet("ASK", OBJPROP_XDISTANCE,10);
    ObjectSet("ASK", OBJPROP_YDISTANCE,45);
    ObjectSetText("ASK", "Precio Venta: " +  ask, 10, "Arial", colorActual);
}

void imprimirCCI34(double CCI_actual, color colorActual){
    ObjectDelete("CCI34");
    ObjectCreate("CCI34", OBJ_LABEL, 0, 0, 0);
    ObjectSet("CCI34", OBJPROP_CORNER, 3);
    ObjectSet("CCI34", OBJPROP_XDISTANCE,10);
    ObjectSet("CCI34", OBJPROP_YDISTANCE,45);
    ObjectSetText("CCI34", "CCI 34p: " +  CCI_actual, 13, "Arial", colorActual);
}

void imprimirCCI46(double CCI_actual, color colorActual){
    ObjectDelete("CCI46");
    ObjectCreate("CCI46", OBJ_LABEL, 0, 0, 0);
    ObjectSet("CCI46", OBJPROP_CORNER, 3);
    ObjectSet("CCI46", OBJPROP_XDISTANCE,10);
    ObjectSet("CCI46", OBJPROP_YDISTANCE,25);
    ObjectSetText("CCI46", "CCI 46p: " +  CCI_actual, 13, "Arial", colorActual);
}

void imprimirMACD(double MACD_actual, color colorActual){
    ObjectDelete("MACD");
    ObjectCreate("MACD", OBJ_LABEL, 0, 0, 0);
    ObjectSet("MACD", OBJPROP_CORNER, 3);
    ObjectSet("MACD", OBJPROP_XDISTANCE,10);
    ObjectSet("MACD", OBJPROP_YDISTANCE,5);
    ObjectSetText("MACD", "MacD: " +  MACD_actual, 13, "Arial", colorActual);
}

void imprimirFlags(){

    ObjectDelete("headers");
    ObjectCreate("headers", OBJ_LABEL, 0, 0, 0);
    ObjectSet("headers", OBJPROP_CORNER, 2);
    ObjectSet("headers", OBJPROP_XDISTANCE,10);
    ObjectSet("headers", OBJPROP_YDISTANCE,35);
    ObjectSetText("headers", "         CCI34  CCI46  MACD" , 9, "Arial", White);
    
    ObjectDelete("header_fila_buy");
    ObjectCreate("header_fila_buy", OBJ_LABEL, 0, 0, 0);
    ObjectSet("header_fila_buy", OBJPROP_CORNER, 2);
    ObjectSet("header_fila_buy", OBJPROP_XDISTANCE,5);
    ObjectSet("header_fila_buy", OBJPROP_YDISTANCE,20);
    ObjectSetText("header_fila_buy", "BUY" , 10, "Arial", White);
    
    ObjectDelete("header_fila_sell");
    ObjectCreate("header_fila_sell", OBJ_LABEL, 0, 0, 0);
    ObjectSet("header_fila_sell", OBJPROP_CORNER, 2);
    ObjectSet("header_fila_sell", OBJPROP_XDISTANCE,5);
    ObjectSet("header_fila_sell", OBJPROP_YDISTANCE,5);
    ObjectSetText("header_fila_sell", "SELL" , 10, "Arial", White);
   
    for(int i=0;i<ArraySize(flag_buy);i++){
      ObjectDelete("fila_buy"+i);
      ObjectCreate("fila_buy"+i, OBJ_LABEL, 0, 0, 0);
      ObjectSet("fila_buy"+i, OBJPROP_CORNER, 2);
      ObjectSet("fila_buy"+i, OBJPROP_XDISTANCE,(40*i)+50);
      ObjectSet("fila_buy"+i, OBJPROP_YDISTANCE,20);
      if(flag_buy[i] == 0)
         ObjectSetText("fila_buy"+i, flag_buy[i], 12, "Arial", Red);
      else
         ObjectSetText("fila_buy"+i, flag_buy[i], 12, "Arial", Green);
    }for(int i=0;i<ArraySize(flag_sell);i++){
      ObjectDelete("fila_sell"+i);
      ObjectCreate("fila_sell"+i, OBJ_LABEL, 0, 0, 0);
      ObjectSet("fila_sell"+i, OBJPROP_CORNER, 2);
      ObjectSet("fila_sell"+i, OBJPROP_XDISTANCE,(40*i)+50);
      ObjectSet("fila_sell"+i, OBJPROP_YDISTANCE,5);
      if(flag_sell[i] == 0)
         ObjectSetText("fila_sell"+i, flag_sell[i], 12, "Arial", Red);
      else
         ObjectSetText("fila_sell"+i, flag_sell[i], 12, "Arial", Green);
    }
}