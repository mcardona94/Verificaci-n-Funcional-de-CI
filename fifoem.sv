// Emulación de FIFO 


class fifo #(parameter cola_size = 5, parameter pckg_sz = 16);
	bit fifo_full;		//Bandera que avisa cuando fifo esta llena
	bit pndg;			//Bandera que avisa cuando fifo esta vacia
	bit [pckg_sz-9:0] cola [$:cola_size-1];   
	
	//Inicializacion de las banderas
	function new();
		this.pndg = 0;
		this.fifo_full = 0;
	endfunction
	
	//Funcion de PUSH
  	function void push(bit [pckg_sz-9:0] paquete, string tag = "");
      	//Verifica si la FIFO esta llena 
      	if (cola.size() == cola_size) begin
			this.fifo_full = 1;
		end
      
		//Asercion sobre si la FIFO esta llena y se le quiere introducir un dato
		v_push: assert (!this.fifo_full) begin
          	$display("Se realiza un PUSH cuando la FIFO %s NO esta llena", tag);
		end else begin
          	$display("Se realiza un PUSH cuando la FIFO %s esta llena", tag);
			$display("ALERTA: OVERFLOW", tag);
		end
      	cola.push_front(paquete); //se realiza el push del paquete a la FIFO
		this.pndg = 1; // Se establece la funcion de pndg en alto 
	endfunction
	
	//Funcion de POP
  	function bit[pckg_sz-9:0] pop(string tag = ""); //se define la funcion de esta forma ya que esta funcion tiene que devolver un dato y no puede ser void
		//Asercion de que no este vacio el FIFO
		v_pop: assert (cola.size() != 0) begin
          	$display("Se realiza POP cuando la FIFO %s NO esta vacia", tag);
		end else begin
          	$display("Se realiza POP cuando la FIFO %s esta vacia", tag);
			$display("ALERTA: UNDERFLOW", tag);
		end	
		//Ahora se realiza el POP del dato proveniente de la FIFO
		if(cola.size() > 0) begin //inicializa el proceso si la FIFO tiene paquetes dentro de la cola
			if(cola.size() == 1) begin	// Si la FIFO solo tiene un elemento en la cola entonces se pone la funcion pndg en 0 porque proximamente estara vacia		
          		this.pndg = 0; //Se pone la funcion de pndg en bajo 
        	end
			return cola.pop_back; //se realiza el POP
		end
		this.fifo_full = 0; // 
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