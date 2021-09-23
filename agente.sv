// Agente/generador

class agente #(parameter pckg_sz = 16, parameter drvrs = 4, parameter brdcst_ind = {8{1'b1}});
	
  	//Control de variables aleatorizadas
	int num_paquetes;
	int max_retardo;
  	int max_dir;
  	int min_dir;
  	int caso_uso;
  	bit [7:0] pck_broadcast;
  	//Uso de los eventos llamados en el ambiente
	event driver_ready; //senal a driver para indicarle que puede ejecutar
  	event agent_done; //senal a checker para indicarle que puede ejecutar
	mailbox agent_drvr_mbx; //llamado del mailbox que comunica el agente con el driver
  	
  	//Variables de control:
	function new();
		num_paquetes = 20;
		max_retardo = 5;
      	max_dir = 20;
      	min_dir = 0;
      	caso_uso = 2;
      	pck_broadcast = 0;
	endfunction
	
	task run();
		$display("[%0t] El agente fue inicializado", $time);
      	case(caso_uso)
          	0: begin //Paquete enviado a multiples dispositivos o drivers 
				for(int i = 0; i< num_paquetes; i++)begin	
					paquete #(.pckg_sz(pckg_sz),.drvrs(drvrs)) pck = new; //creacion de objeto de la clase paquete
          			pck.max_retardo = this.max_retardo; //Asignacion del valor de retardo maximo al objeto paquete
					pck.max_dir = drvrs-1; // Asignacion del valor maximo de dispositivos al objeto paquete
					pck.min_dir = 0; // Asignacion del valor minimo de dispositivos al objeto paquete
					pck.randomize(); //Aleatorizacion de parametros aleatorizablez que contiene el paquete
                  	while(pck.destino == pck.disp_origen)begin
                      	pck.randomize();
                  	end
                  	if(pck.destino ==  brdcst_ind) begin //Si se incluye broadcast en el paquete activa bandera
            			pck.bandera_broadcast = 1;
          			end else begin
              			pck.bandera_broadcast = 0;
            		end
					$display("[%0t] Agente: Transaccion de paquete %0d/%0d ", $time, i+1,num_paquetes);
          			agent_drvr_mbx.put(pck);//Introduce el paquete en el mailbox para enviarselo al driver
					@(driver_ready); // Se reporta el fin del evento que indica que el driver esta listo para ejecutar
				end
            end
          	1: begin //Paquete enviado a un solo dispositivo
				for(int i = 0; i< num_paquetes; i++)begin	
					paquete #(.pckg_sz(pckg_sz),.drvrs(drvrs)) pck = new;
					//Preparacion de paquete
          			pck.max_retardo = this.max_retardo;
					pck.max_dir = max_dir;
					pck.min_dir = min_dir;
					pck.randomize();
                  	pck.disp_origen = pck_broadcast;
                  	while(pck.destino == pck.disp_origen)begin
                      	pck.randomize();
                  	end
					$display("[%0t] Agente: Transaccion de paquete a dispositivo %0d/%0d ", $time, i+1,num_paquetes);
          			agent_drvr_mbx.put(pck);//Espera a que el driver termine de enviar un paquete
					@(driver_ready);
				end
            end
          	2:begin //paquete que se le envia a todos los dispositivos (BROADCAST)
      			for(int i = 0; i< num_paquetes; i++)begin	
					paquete #(.pckg_sz(pckg_sz),.drvrs(drvrs)) pck = new;
          			pck.max_retardo = this.max_retardo;
					pck.max_dir = max_dir;
					pck.min_dir = min_dir;
					pck.randomize();
                  	pck.destino = brdcst_ind; //Esto hace que el destino sea igual al broadcast, lo que significaria que le esta enviando el paquete a todos los dispositivos
                  	if(pck.destino ==  brdcst_ind) begin 
            			pck.bandera_broadcast = 1;
          			end else begin
              			pck.bandera_broadcast = 0;
            		end
					$display("[%0t] Agente: Transaccion de paquete con broadcast %0d/%0d ", $time, i+1,num_paquetes);
          			agent_drvr_mbx.put(pck);
					@(driver_ready);
				end
            end
        	default: begin //  ALEATORIZA TODO 
				$display("Agente: Se realiza una transaccion invalida.");
            end
        endcase  
		#120000;
		->agent_done;//Le reporta al checker que ya termino de trabajar 
	endtask
endclass