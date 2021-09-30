// Emulación de FIFO 

class fifo #(parameter cola_size = 5, parameter pckg_sz = 16);
	bit fifo_full;		//Bandera que avisa cuando la FIFO esta llena
	bit pndg;			//Bandera que avisa cuando la FIFO esta vacia
	bit [pckg_sz-1:0] cola [$:cola_size-1];  //creacion de arreglo cola  
	
	//Inicializacion de las banderas
	function new();
		this.pndg = 0;
		this.fifo_full = 0;
	endfunction
	
	//Funcion de PUSH
  	function void push(bit [pckg_sz-1:0] mensaje, string tag = "");
      	//Verifica si la FIFO esta llena 
      	if (cola.size() == cola_size) begin
			this.fifo_full = 1;
		end
		//Asercion para verificar que se le hizo PUSH a un dato cuando la FIFO no esta llena
		v_push: assert (!this.fifo_full) begin
          	$display("Se realiza PUSH cuando la FIFO %s no esta llena", tag);
		end else begin
          	$display("Error: se realiza PUSH cuando la FIFO %s esta llena", tag);
		end
		
      	cola.push_front(mensaje);
		this.pndg = 1;
	endfunction
	
	//Funcion de POP
  	function bit[pckg_sz-1:0] pop(string tag = "");
		//Asercion para verificar que la FIFO no esta vacia cuando se quiere hacer un POP 
		v_pop: assert (cola.size() != 0) begin
          	$display("Se realiza un POP cuando la FIFO %s no esta vacia", tag);
		end else begin
          	$display("Error: se realiza un POP cuando la FIFO %s esta vacia", tag);
		end	
		if(cola.size() > 0) begin
			if(cola.size() == 1) begin			
          		this.pndg = 0; 		
        	end
			return cola.pop_back;
		end
		
		this.fifo_full = 0;
	endfunction
  	//Funcion para saber si la cola esta vacia
  	function bit get_pndg();
      	if(cola.size() == 0) begin
          	this.pndg = 0;
        end
    	return this.pndg;
    endfunction;
  	
  	//Funcion para obtener tamaño de cola
  	function int get_size();
      return this.cola.size();
    endfunction;
endclass