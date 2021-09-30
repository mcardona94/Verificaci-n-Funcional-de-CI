// Clases para las transacciones

class mensaje #(parameter pckg_sz = 16, parameter drvrs = 4);
	
	rand bit [7:0] destino; //Destino de la informacion
	rand bit [pckg_sz-9:0] datos; // Bits de informacion
	rand bit [7:0] fuente; //Driver que envia los datos
	rand int tiempo_retardo; //Tiempo de retraso 
	bit flg_brdcst; //Bandera para saber si genera mensaje de broadcast
	int max_retardo;//control de retardo 
	int max_destino; //Maxima direccion generada
	int min_destino; //Minima direccion generada
	
  	constraint my_range {fuente inside {[0:drvrs-1]};} //Constraint para que no se envien mensajes de un disp inexistente
	
	constraint delay_range {tiempo_retardo inside {[0:max_retardo]};} //Constraint para que el tiempo no sea negativo ni demasiado grande
	
	constraint dest_range {destino inside {[min_destino:max_destino]};} //Constraint para controlar rango de destino
	
	function void inf_reporte_consola (string tag = "");
      	$display("[%s] tiempo_retardo=%g flg_brdcst = 0x%0h fuente=0x%0h destino=0x%0h datos=0x%0h",
					 tag,tiempo_retardo,flg_brdcst, fuente, destino, datos);
	endfunction

endclass

// Transaccion driver_CHCKR (enviada desde el driver) 

class Trans_driver_chckr #(parameter pckg_sz = 32);
	
  	//Datos del paquete
 	bit [7:0] destino; 
	bit [pckg_sz-9:0] dato;
	bit [7:0] fuente;
  	bit brdcst;
	int tiempo_envio;
	
  	//Inicializa los valores
    function new();
      this.dato = 0;
      this.destino = 0;
      this.tiempo_envio = 0;	
      this.fuente = 0;
      this.brdcst = 0; 
    endfunction 

	function void reporte_consola (string tag = "");
      $display("[%s] tiempo_envio=%0d fuente=0x%0h destino=0x%0h datos=0x%0h, brdcst = %0d ",
		tag,tiempo_envio, fuente, destino, dato, brdcst);
	endfunction

endclass

//Transaccion trans_monitor_checker  (Enviada desde monitor a checker)    
            
class trans_monitor_checker #(parameter pckg_sz=16);
  	//Datos del paquete recibido 
    bit [pckg_sz-9:0] dato;
    bit [7:0] receptor;
    int tiempo_recepcion;
    
  	//Inicializa los parametros del objeto transaccion
    function new();
      this.dato = 0;
      this.receptor = 0;
    	this.tiempo_recepcion = 0;	
    endfunction 

    function void reporte_consola (string tag = "");
        $display("[%0t] %0s msj del dispositivo 0x%0h, Datos=0x%0h, t_recive = %0d",$time, tag, receptor,dato, tiempo_recepcion);
    endfunction
endclass      

//Transaccion que contiene Resultados    

class trans_resultados #(parameter pckg_sz=10);
    
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

    function void reporte_consola (string tag = "");
        $display("[%0t] [%0s] [Pass] transaccion completada Fuente=0x%0h, Destino=0x%0h, Dato enviado=0x%0h, Dato recibido=0x%0h,Receptor=0x%0h, t_recive = %0d, tiempo_envio=%0d, delay = %0d",$time, tag, fuente, destino, dato_enviado, dato_recibido, receptor, tiempo_recepcion, tiempo_envio, delay);
    endfunction
endclass