// Este modulo se encarga de recibir los resultados de cada transaccion o aviso generado y los introduce a un reporte (archivo .csv)\

class score_board #(parameter pckg_sz=16);
  int csvFile;
  string line;
    //Datos del mensaje 
  bit [7:0] fuente;
  bit [7:0] destino;
  bit [7:0] receptor;
  bit [pckg_sz-9:0] dato_enviado;
  bit [pckg_sz-9:0] dato_recibido;
  int tiempo_recepcion;
  int tiempo_envio;
  int delay;

	//Inicializa los valores
  function new();
      this.fuente = 0;
      this.destino = 0;
      this.receptor = 0;
   	  this.dato_enviado = 0;
   	  this.dato_recibido = 0;
      this.tiempo_recepcion = 0;	
      this.tiempo_envio = 0;
      this.delay = 0;
  endfunction 
/// Esta funcion me crea el archivo .csv para poder escribir en el

  function void openReport();
    csvFile = $fopen ("./Scoreboard.csv", "a");
  endfunction

/// Esta funcion es para escribir en el archivo de reporte abierto anteriormente toda la informacion de las transacciones realizadas
  
  function void writeReport(string tag = "");
    $fdisplay(csvFile, "[%0t] %0s Fuente=0x%0h, Destino=0x%0h, Dato enviado=0x%0h, Dato recibido=0x%0h,Receptor=0x%0h, t_recive = %0d, tiempo_envio=%0d, delay = %0d",$time, tag, fuente, destino, dato_enviado, dato_recibido, receptor, tiempo_recepcion, tiempo_envio, delay);
  endfunction
  
  function void closeReport();
    $fclose(csvFile);
  endfunction
  
endclass
    
  
