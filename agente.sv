// Agente/generador


class agente #(parameter pckg_sz = 16, parameter drvrs = 4, parameter brdcst_ind = {8{1'b1}});
	int csvFile;
    string line;
  	//Creacion de variables de la clase
	int num_msjs;
	int max_retardo;
  	int max_destino;
  	int min_destino;
  	int caso_uso;
  	bit [7:0] broadcast_ind;
	event driver_func; //evento que va a reportar la conclusion del funcionamiento del driver
  	event agent_func; //evento que va a reportar la conclusion del funcionamiento del agente 
	mailbox agent_drvr_mbx; //Mailbox del driver
  	
  	//Inicializa variables de control
	function new();
		num_msjs = 20;
		max_retardo = 5;
      	max_destino = 0;
      	min_destino = 0;
      	caso_uso = 0;
      	broadcast_ind = 0;
	endfunction
	
	task run();
		$display("[%0t] El agente fue inicializado", $time);
      	case(caso_uso)
          	0: begin //Generacion de transacciones a varios dispositivos con aleatoriedad 
      			
				for(int i = 0; i< num_msjs; i++)begin	
					mensaje #(.pckg_sz(pckg_sz),.drvrs(drvrs)) msj = new;
					//Preparacion de mensaje
          			msj.max_retardo = this.max_retardo;
					msj.max_destino = drvrs-1;
					msj.min_destino = 0;
					msj.randomize();
                  	while(msj.destino == msj.fuente)begin
                      	msj.randomize();
                  	end
                  	if(msj.destino ==  brdcst_ind) begin //Si se genera un codigo de brdcst prepara la bandera
            			msj.flg_brdcst = 1;
          			end else begin
              			msj.flg_brdcst = 0;
            		end
			$display("[%0t] Agente: Transaccion %0d/%0d creada", $time, i+1,num_msjs);
        		agent_drvr_mbx.put(msj);//Espera a que el driver termine de enviar un mensaje
			@(driver_func);
			end
            end
          	1: begin //Broadcast 
      			
				for(int i = 0; i< num_msjs; i++)begin	
					mensaje #(.pckg_sz(pckg_sz),.drvrs(drvrs)) msj = new;
					//Preparacion de mensaje
          			msj.max_retardo = this.max_retardo;
					msj.max_destino = max_destino;
					msj.min_destino = min_destino;
					msj.randomize();
                  	msj.destino = brdcst_ind;
                  	if(msj.destino ==  brdcst_ind) begin //Si se genera un codigo de brdcst prepara la bandera
            			msj.flg_brdcst = 1;
          			end else begin
              			msj.flg_brdcst = 0;
            		end
					$display("[%0t] Agente: Transaccion con Broadcast %0d/%0d creada", $time, i+1,num_msjs);
          			agent_drvr_mbx.put(msj);//Espera a que el driver termine de enviar un mensaje
					@(driver_func);
				end
            end
        	default:begin // Caso de uso invalido 
              $display("Error: Caso de uso invalido.");
            end 
        endcase  
		#120000;
		->agent_func;//Reporta la finalizacion del funcionamiento del agente
	endtask
endclass
