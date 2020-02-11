/*Forecasting Quarterly Freight Volumes*/
/* Lakshmi Palaparambil Dinesh*/
/*2/20/2013*/
DATA CASE5;
DO YEAR=1965 TO 1978;
   DO QUARTER=1 TO 4;
      DATE=YYQ(YEAR,QUARTER);one=1;
      INPUT VOLUME @@; OUTPUT;
   END;
END;
/*LABEL VOLUME=QUARTERLY FREIGHT VOLUME BY RAILROAD;*/
KEEP DATE VOLUME one; FORMAT DATE YYQ4.;
CARDS;
166.8 172.8 178.3 180.3 182.6 184.2 188.9 184.4 181.7 178.5
177.6 181.0 186.5 185.7 186.4 186.3 189.3 190.6 191.7 196.1
189.3 192.6 192.1 189.4 189.7 191.9 182   175.7 192   192.8
193.3 200.2 208.8 211.4 214.4 216.3 221.8 217.1 214   202.4
191.7 183.9 185.2 194.5 195.8 198   200.9 199   200.6 209.5
208.4 206.7 193.3 197.3 213.7 225.1
;
PROC PRINT;
%dftest (case5,volume,outstat=one)
proc print data=one;run;
%dftest (case5,volume,dif=(1),outstat=two)
proc print data=two;run;
PROC ARIMA data=case5; 
IDENTIFY  VAR=VOLUME nlag=14 stationarity=(adf) MINIC SCAN ESACF;
Estimate p=1 plot; run;
PROC ARIMA data=case5; 
IDENTIFY  VAR=VOLUME(1)nlag=14 stationarity=(adf)  MINIC SCAN ESACF;
Estimate p=0 q=0 plot noconstant; run;
PROC ARIMA data=case5; 
IDENTIFY  VAR=VOLUME nlag=14 ;  
Estimate p=1 q=1 plot ; run;
PROC ARIMA data=case5;
IDENTIFY  VAR=VOLUME(1) nlag=14;
Estimate p=0 q=1 plot noconstant; 
forecast out=fore lead=12;
run;
data new;set fore;one=1;
data forecast;merge new case5;by one;
keep volume date forecast l95 u95;
goptions cback=white colors=(black) border reset=(axis symbol);
axis1 offset=(1 cm)
      label=('Year') minor=none;
axis2 label=(angle=90 'Volume')
      order=(160 to 240 by 10);
symbol1 i=join l=1 h=2 pct v=star;

proc gplot data=case5;
   format date yyq4.;
   plot volume*date=1/
                     haxis=axis1
                     vaxis=axis2
                     vminor=1;
Title "FREIGHT VOLUME";
run;

proc gplot data=forecast;
   symbol1 i=none    v=star h=.8;
   symbol2 i=spline  v=circle h=.2;
   symbol3 i=spline l=20 color=black;
      plot volume*date = 1
	  forecast*date = 2
	  ( l95 u95 )*date = 3/
	  overlay ;
   format date yyq4.;
   Title "FORECASTS OF FREIGHT VOLUME";run;
