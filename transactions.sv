// Clases para las transacciones


// Definicion del objeto paquete:
class paquete #(parameter pckg_sz = 16, parameter drvrs = 4);
	
	rand bit [7:0] destino; //Variable aleatorizable que indica el destino del paquete
	rand bit [pckg_sz-9:0] datos; // Informacion del paquete de datos aleatorizable
	rand bit [drvrs-1:0] disp_origen; //Driver de origen de los datos aleatorizable
	rand int retardo_aleatorio; //Tiempo de retardo aleatorizable 
	bit bandera_broadcast; //Bandera que avisa si se realiza un broadcast
	int max_retardo;//valor maximo del tiempo de retardo definido
	int max_dir; //Maxima direccion generada
	int min_dir; //Minima direccion generada
	
  	constraint rango_origen {disp_origen inside {[0:drvrs-1]};} //Constraint para que se haga la transaccion desde un dispositivo dentro de la cantidad creada (de 0 a cantidad de drivers -1)
	
	constraint rango_retardo {retardo_aleatorio inside {[0:max_retardo]};} //Constraint para definir el rango de valores del tiempo de retardo aleatorizable
	
	constraint rango_destino {destino inside {[min_dir:max_dir]};} //Constraint para controlar rango de valores de destino
	
	function void print_paquete (string tag = "");
      	$display("[%s] retardo_aleatorio=%g bandera_de_broadcast = 0x%0h dispositivo_origen=0x%0h destino=0x%0h datos=0x%0h",
					 tag,retardo_aleatorio,bandera_broadcast, disp_origen, destino, datos);
	endfunction

endclass

// Transaccion de driver a checker

class trans_driver_checker #(parameter pckg_sz = 16);
	
  	//Datos para que el checker sepa el paquete enviado
 	bit [7:0] destino; 
	bit [pckg_sz-9:0] dato;
	bit [7:0] disp_origen;
  	bit brdcst;
	int t_envio;
	
  	//Inicializa los valores de los objetos de la transaccion 
    function new();
      this.dato = 0;
      this.destino = 0;
      this.t_envio = 0;	
      this.disp_origen = 0;
      this.brdcst = 0; 
    endfunction 

	function void print (string tag = "");
      $display("[%s] t_envio=%0d disp_origen=0x%0h destino=0x%0h datos=0x%0h, brdcst = %0d ",
		tag,t_envio, disp_origen, destino, dato, brdcst);
	endfunction
endclass

//Transaccion enviada desde monitor a checker)    
      
class trans_monitor_checker #(parameter pckg_sz=16);
  	//Informacion de dato recibido 
    bit [pckg_sz-9:0] dato;
    bit [7:0] receptor;
    int t_recepcion;
    
  	//Inicializa los valores
    function new();
      this.dato = 0;
      this.receptor = 0;
      this.t_recepcion = 0;	
    endfunction 

    function void print (string tag = "");
        $display("[%0t] %0s Dispositivo: 0x%0h, Datos=0x%0h, tiempo_de_recepcion = %0d",$time, tag, receptor,dato, t_recepcion)
    endfunction
endclass      

//Transaccion Resultado (Empaqueta los resultados de envio)     

class Trans_resultado #(parameter pckg_sz=16);
    
  	//Datos del paquete 
    bit [7:0] disp_origen;
    bit [7:0] destino;
	bit [7:0] receptor;
    bit [pckg_sz-9:0] dato_enviado;
    bit [pckg_sz-9:0] dato_recibido;
    int t_recepcion;
    int t_envio;
    int delay;

	//Inicializa los valores
    function new();
        this.disp_origen = 0;
        this.destino = 0;
        this.receptor = 0;
    	this.dato_enviado = 0;
      	this.dato_recibido = 0;
        this.t_recepcion = 0;	
        this.t_envio = 0;
        this.delay = 0;
    endfunction 

    function void print (string tag = "");
        $display("[%0t] [%0s] Transaccion completada dispositivo_origen=0x%0h, Destino=0x%0h, Dato enviado=0x%0h, Dato recibido=0x%0h,Receptor=0x%0h, t_recive = %0d, t_envio=%0d, delay = %0d",$time, tag, disp_origen, destino, dato_enviado, dato_recibido, receptor, t_recepcion, t_envio, delay);
    endfunction
endclass