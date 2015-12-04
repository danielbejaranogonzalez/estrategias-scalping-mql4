//+------------------------------------------------------------------+
//|                                          Estrategia_Reina_v5.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

// Variables
int timeFrame = PERIOD_M1;
int periodo = 4;
int ma_shift = 0;
int ma_metodo = MODE_EMA;
int applied_price = PRICE_CLOSE;
int shift = 5;

int ticketNumberActual[1]={0};
int tiempoInicioOperaciones[1]= {0};
int stopLossArrayActual[1]= {0};
string nombresOperaciones[1]={"A"};
string statusOperaciones[1]= {"SIN OPERACION"};
int perdidasConsecutivas[1]= {0};
int arranqueAlgoritmo[1]= {0};
int profitUltimaOperacion[1] = {0};

int statusTimer = 0;
int total_segundos=0;
double pendienteActual=0;

double STOP_LOSS_ARRAY_START[1]={28};
double TAKE_PROFIT[1]={22};

double VOLUMEN_START[1]={0.01};
double VOLUMEN[1]={0.01};
double TICKS_PENDIENTE = 5;
double PENDIENTE_LIMITE = 2.9;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
      pendienteActual = realizarRegresionMediaMovil(TICKS_PENDIENTE);
      if(pendienteActual <= -PENDIENTE_LIMITE){
         ticketNumberActual[0] = OrderSend(Symbol(),OP_BUY,VOLUMEN[0],Ask,3, Ask-STOP_LOSS_ARRAY_START[0]*Point, Ask+TAKE_PROFIT[0]*Point, NULL,0,0,Green);
         tiempoInicioOperaciones[0] = total_segundos;
         statusOperaciones[0] = "EN OPERACION";
         arranqueAlgoritmo[0] = 1;
      }else if(pendienteActual >= PENDIENTE_LIMITE){
         ticketNumberActual[0] = OrderSend(Symbol(),OP_SELL,VOLUMEN[0],Bid,3, Bid+STOP_LOSS_ARRAY_START[0]*Point, Bid-TAKE_PROFIT[0]*Point, NULL,0,0,Red);
         tiempoInicioOperaciones[0] = total_segundos;
         statusOperaciones[0] = "EN OPERACION";
         arranqueAlgoritmo[0] = 1;
      }
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
    marcar_timer(60);
    ejecutarOperaciones(pendienteActual);
    
    //Ejecutar
    if(statusTimer == 1){
      pendienteActual = realizarRegresionMediaMovil(TICKS_PENDIENTE);
      //Validar Operaciones Actuales
      validarOperacionesFinalizadas();
    }
    
    ejecutarMartingale();
    
    //Impresiones en Pantalla
    printTimer();
    printDashBoard();
    printVolumenes();
  }
//+------------------------------------------------------------------+

void validarOperacionesFinalizadas(){
    int hstTotal=OrdersHistoryTotal();
    int order;
    
    if(true){
      for(int i=0;i<hstTotal;i++){
        if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==true){
           order=OrderTicket();
           for(int j=0; j < ArraySize(ticketNumberActual);j++){
              if(order == ticketNumberActual[j]){
                 aplicarMartingaleDirecta();
                 tiempoInicioOperaciones[j] = 0;
                 statusOperaciones[j] = "SIN OPERACION";
                 profitUltimaOperacion[j] = OrderProfit();
              }
           }
        }else{
           Print("OrderSelect failed error code is",GetLastError());
        }
      }
    }
   printTotalOrdersHistory(hstTotal, Orange);
}

void ejecutarMartingale(){

   for(int i = 0; i < ArraySize(ticketNumberActual); i++){
      if(tiempoInicioOperaciones[i] == 0 && arranqueAlgoritmo[i]== 1){
         if(profitUltimaOperacion[i] < 0){
            if(perdidasConsecutivas[i] <= 2)
               VOLUMEN[i] = VOLUMEN[i] * 3.3;
            else if(perdidasConsecutivas[i] == 3){
               VOLUMEN[i] = VOLUMEN[i] * 2.2;
               TICKS_PENDIENTE = 8;
               PENDIENTE_LIMITE = 4.2;
            }else if(perdidasConsecutivas[i] == 4){
               VOLUMEN[i] = VOLUMEN[i] * 2;
               TICKS_PENDIENTE = 8;
               PENDIENTE_LIMITE = 4.2;
            }else if(perdidasConsecutivas[i] == 5){
               VOLUMEN[i] = VOLUMEN[i] * 0.6;
               TICKS_PENDIENTE = 10;
               PENDIENTE_LIMITE = 4.5;
            }else if(perdidasConsecutivas[i] == 6){
               VOLUMEN[i] = VOLUMEN[i] * 0.6;
               TICKS_PENDIENTE = 10;
               PENDIENTE_LIMITE = 4.5;
            }else if(perdidasConsecutivas[i] >= 7){
               VOLUMEN[i] = VOLUMEN[i] * 0.5;
               TICKS_PENDIENTE = 10;
               PENDIENTE_LIMITE = 4.5;
            }
            
             perdidasConsecutivas[i] = perdidasConsecutivas[i] + 1;
             arranqueAlgoritmo[i] = 0;
         }else if(profitUltimaOperacion[i] >= 0){
            VOLUMEN[i] = VOLUMEN_START[i];
            arranqueAlgoritmo[i] = 0;
            perdidasConsecutivas[i] = 0;
         }
      }
   }
   
}

void ejecutarOperaciones(double pendiente){
   for(int i=0; i < ArraySize(ticketNumberActual); i++){
      if(statusOperaciones[i] == "SIN OPERACION" && OrdersTotal() <= 0){
         if(pendienteActual <= -PENDIENTE_LIMITE){
            ticketNumberActual[i] = OrderSend(Symbol(),OP_BUY,VOLUMEN[i],Ask,3, Ask-STOP_LOSS_ARRAY_START[i]*Point, Ask+TAKE_PROFIT[i]*Point, NULL,0,0,Green);
            tiempoInicioOperaciones[i] = total_segundos;
            statusOperaciones[i] = "EN OPERACION";
            arranqueAlgoritmo[i] = 1;
            break; 
         }else if(pendienteActual >= PENDIENTE_LIMITE){
            ticketNumberActual[i] = OrderSend(Symbol(),OP_SELL,VOLUMEN[i],Bid,3, Bid+STOP_LOSS_ARRAY_START[i]*Point, Bid-TAKE_PROFIT[i]*Point, NULL,0,0,Red);
            tiempoInicioOperaciones[i] = total_segundos;
            statusOperaciones[i] = "EN OPERACION";
            arranqueAlgoritmo[i] = 1;
            break;
         }
         break;
      }
   }
}

//FUNCIONES GENERALES
double realizarRegresionMediaMovil(int ticks){
   double sumatoria_MAs = 0, promedio_MAs = 0, promedioTiempos = 0;
   int sumatoriaTiempos = 0;
   double O1, O2;
   double pendiente = 0;
   
   //calculo de sumatorias
   for(int j = 1; j <= ticks; j++){
      sumatoria_MAs = sumatoria_MAs + iMA(NULL,timeFrame,periodo,ma_shift,ma_metodo,applied_price, j);
      sumatoriaTiempos = sumatoriaTiempos + j;
   }
   
   //Calculo de Promedios
   promedio_MAs = sumatoria_MAs / ticks;
   promedioTiempos = sumatoriaTiempos / ticks;
   //Calculo de la Pendiente de la Regresion de la Recta
   for(int k = 1; k <= ticks; k++){
      O1 = O1 +((k-promedioTiempos)*(iMA(NULL,timeFrame,periodo,ma_shift,ma_metodo,applied_price, k)-promedio_MAs));
      O2 = O2 +(MathPow(k-promedioTiempos,2));
   }
   if(O1 != 0 && O2 != 0)
      pendiente = O1/O2;
   else
      pendiente = 0;
   double pendienteAmp = pendiente * (10000) * (-1);
   
   if(pendienteAmp >= -PENDIENTE_LIMITE && pendienteAmp <= PENDIENTE_LIMITE)
      printPendiente(pendienteAmp, Orange);
   else
      printPendiente(pendienteAmp, Green);
   
   return(pendienteAmp);
}

void marcar_timer(int limite){
   total_segundos= Seconds()+(Minute()*60)+(Hour()*3600)+(Day()*86400)+(Month()*10000000);
   if(total_segundos%limite == 0){
      statusTimer = 1;
   }else
      statusTimer = 0;
}

//FUNCIONES DE IMPRESION EN PANTALLA
void printPendiente(double pendienteMediaMovil, color colorActual){
    ObjectDelete("PENDIENTE");
    ObjectCreate("PENDIENTE", OBJ_LABEL, 0, 0, 0);
    ObjectSet("PENDIENTE", OBJPROP_CORNER, 3);
    ObjectSet("PENDIENTE", OBJPROP_XDISTANCE,10);
    ObjectSet("PENDIENTE", OBJPROP_YDISTANCE,10);
    ObjectSetText("PENDIENTE", "M: " +  pendienteMediaMovil , 14, "Arial", colorActual);
}

void printTotalOrdersHistory(double totalOrders, color colorActual){
    ObjectDelete("ORDERS");
    ObjectCreate("ORDERS", OBJ_LABEL, 0, 0, 0);
    ObjectSet("ORDERS", OBJPROP_CORNER, 3);
    ObjectSet("ORDERS", OBJPROP_XDISTANCE,10);
    ObjectSet("ORDERS", OBJPROP_YDISTANCE,50);
    ObjectSetText("ORDERS", "#Orders: " + totalOrders, 14, "Arial", colorActual);
}

void printTimer(){
    ObjectDelete("total_segundos");
    ObjectCreate("total_segundos", OBJ_LABEL, 0, 0, 0);
    ObjectSet("total_segundos", OBJPROP_CORNER, 3);
    ObjectSet("total_segundos", OBJPROP_XDISTANCE,10);
    ObjectSet("total_segundos", OBJPROP_YDISTANCE,30);
    
    if(statusTimer == 1)
      ObjectSetText("total_segundos", "Time [s]: " +  total_segundos + " - " + statusTimer , 14, "Arial", Green);
    else
      ObjectSetText("total_segundos", "Time [s]: " +  total_segundos + " - " + statusTimer , 14, "Arial", White);
}

void printDashBoard(){
    ObjectDelete("TITULOS");
    ObjectCreate("TITULOS", OBJ_LABEL, 0, 0, 0);
    ObjectSet("TITULOS", OBJPROP_CORNER, 1);
    ObjectSet("TITULOS", OBJPROP_XDISTANCE,25);
    ObjectSet("TITULOS", OBJPROP_YDISTANCE,5);
    ObjectSetText("TITULOS", "OPERAC. " + "#TICKET  " + "TIMER[m]   " + "Ultim. Profit", 10, "Courier New", Yellow);
    
    for(int i=0; i< 4; i++){
       for(int j=0; j<ArraySize(ticketNumberActual);j++){
         ObjectDelete("CELDA"+i+j);
         ObjectCreate("CELDA"+i+j, OBJ_LABEL, 0, 0, 0);
         ObjectSet("CELDA"+i+j, OBJPROP_CORNER, 1);
         ObjectSet("CELDA"+i+j, OBJPROP_XDISTANCE,(70*i+20));
         ObjectSet("CELDA"+i+j, OBJPROP_YDISTANCE,(15*j)+25);
         
         if(i==3)
            ObjectSetText("CELDA"+i+j, nombresOperaciones[j], 11, "Courier New", Yellow);
         else if(i==2)
            ObjectSetText("CELDA"+i+j, "#" + ticketNumberActual[j] , 10, "Courier New", White);
         else if(i==1){
            if(tiempoInicioOperaciones[j] == 0)
               ObjectSetText("CELDA"+i+j, "N/A" , 10, "Courier New", Red);
            else if(tiempoInicioOperaciones[j] != 0)
               ObjectSetText("CELDA"+i+j, "" + (total_segundos - tiempoInicioOperaciones[j])/60, 10, "Courier New", Green); 
         }else if(i==0){
            ObjectSetText("CELDA"+i+j, "" + profitUltimaOperacion[j], 10, "Courier New", White);
         }
       }
    }
}

void printVolumenes(){
    ObjectDelete("BALANCE");
    ObjectCreate("BALANCE", OBJ_LABEL, 0, 0, 0);
    ObjectSet("BALANCE", OBJPROP_CORNER, 3);
    ObjectSet("BALANCE", OBJPROP_XDISTANCE,10);
    ObjectSet("BALANCE", OBJPROP_YDISTANCE,70);
    ObjectSetText("BALANCE", "Volumenes: " + perdidasConsecutivas[0] + " :" + profitUltimaOperacion[0], 14, "Arial", Orange);
}

/*
*/
 void validar_Operaciones_de_Riesgo(){
   // si tiempo del trade tiene media hora de dif. con el tiempo actual, tomar el trade y acortar el Stoploos 
   //double nuevoStopLoss = 0;
   for(int i = 0; i < ArraySize(ticketNumberActual); i++){
      int tiempoOperacion = total_segundos - tiempoInicioOperaciones[i];
      OrderSelect(ticketNumberActual[i],SELECT_BY_POS);
      
      if(ticketNumberActual[i] != 0){
         if(tiempoOperacion >= 600 && tiempoOperacion < 3600){//tras 40 minutos
               if(OrderType() == OP_BUY)
                  stopLossArrayActual[i]= (OrderOpenPrice()-STOP_LOSS_ARRAY_START[i]*Point)+(10*Point);
               else if(OrderType() == OP_SELL)
                  stopLossArrayActual[i]= (OrderOpenPrice()+STOP_LOSS_ARRAY_START[i]*Point)-(10*Point);
               OrderModify(OrderTicket(),OrderOpenPrice(),stopLossArrayActual[i],OrderTakeProfit(),0,Red);
         }else if(tiempoOperacion >= 3600 && tiempoOperacion < 4800){//tras 1 hora
               if(OrderType() == OP_BUY)
                  stopLossArrayActual[i]= (OrderOpenPrice()-STOP_LOSS_ARRAY_START[i]*Point)+(15*Point);
               else if(OrderType() == OP_SELL)
                  stopLossArrayActual[i]= (OrderOpenPrice()+STOP_LOSS_ARRAY_START[i]*Point)-(15*Point);
               OrderModify(OrderTicket(),OrderOpenPrice(),stopLossArrayActual[i],OrderTakeProfit(),0,Red);
         }else if(tiempoOperacion >= 4800 && tiempoOperacion < 7200){// tras 1 hora y 20 minutos
               if(OrderType() == OP_BUY)
                  stopLossArrayActual[i]= (OrderOpenPrice()-STOP_LOSS_ARRAY_START[i]*Point)+(20*Point);
               else if(OrderType() == OP_SELL)
                  stopLossArrayActual[i]= (OrderOpenPrice()+STOP_LOSS_ARRAY_START[i]*Point)-(20*Point);
               OrderModify(OrderTicket(),OrderOpenPrice(),stopLossArrayActual[i],OrderTakeProfit(),0,Red);
         }else if(tiempoOperacion >= 7200 && tiempoOperacion < 14400){// tras 2 horas
               if(OrderType() == OP_BUY)
                  stopLossArrayActual[i]= (OrderOpenPrice()-STOP_LOSS_ARRAY_START[i]*Point)+(25*Point);
               else if(OrderType() == OP_SELL)
                  stopLossArrayActual[i]= (OrderOpenPrice()+STOP_LOSS_ARRAY_START[i]*Point)-(25*Point);
               OrderModify(OrderTicket(),OrderOpenPrice(),stopLossArrayActual[i],OrderTakeProfit(),0,Red);
         }else if(tiempoOperacion >= 14400 && tiempoOperacion < 21600){// tras 4 horas
               if(OrderType() == OP_BUY)
                  stopLossArrayActual[i]= (OrderOpenPrice()-STOP_LOSS_ARRAY_START[i]*Point)+(30*Point);
               else if(OrderType() == OP_SELL)
                  stopLossArrayActual[i]= (OrderOpenPrice()+STOP_LOSS_ARRAY_START[i]*Point)-(30*Point);
               OrderModify(OrderTicket(),OrderOpenPrice(),stopLossArrayActual[i],OrderTakeProfit(),0,Red);
         }else if(tiempoOperacion >= 21600 && tiempoOperacion < 28800 ){// tras 6 horas
               if(OrderType() == OP_BUY)
                  stopLossArrayActual[i]= (OrderOpenPrice()-STOP_LOSS_ARRAY_START[i]*Point)+(35*Point);
               else if(OrderType() == OP_SELL)
                  stopLossArrayActual[i]= (OrderOpenPrice()+STOP_LOSS_ARRAY_START[i]*Point)-(35*Point);
               OrderModify(OrderTicket(),OrderOpenPrice(),stopLossArrayActual[i],OrderTakeProfit(),0,Red);
         }else if(tiempoOperacion >= 28800){// tras 8 horas
               if(OrderType() == OP_BUY)
                  stopLossArrayActual[i]= (OrderOpenPrice()-STOP_LOSS_ARRAY_START[i]*Point)+(40*Point);
               else if(OrderType() == OP_SELL)
                  stopLossArrayActual[i]= (OrderOpenPrice()+STOP_LOSS_ARRAY_START[i]*Point)-(40*Point);
               OrderModify(OrderTicket(),OrderOpenPrice(),stopLossArrayActual[i],OrderTakeProfit(),0,Red);
         }
      }
   }
 }
 
 void aplicarMartingaleDirecta(){
   /*
   for(int i = 0; i < ArraySize(VOLUMEN); i++){
      if(perdidasConsecutivas[i] == 0){
        VOLUMEN[i] = VOLUMEN_START[i];
      }if(perdidasConsecutivas[i] == 1){
        VOLUMEN[i] = VOLUMEN[i] * 2;
      }
   }
   */
 }