//Checker/scoreboard

class Checker #(parameter drvrs=4, parameter pckg_sz=16); 
	//variables de control
	int k[$];
  	int delay[$];
    // instanciacion de mailboxes 
    mailbox mntr_chkr_mbx;  
    mailbox drvr_chkr_mbx;
  	event flag_end;	//evento que va a indicar cuando termina el envío de datos (viene de agente), se sincroniza con el evento agent_done del agente

  	trans_driver_checker #(.pckg_sz(pckg_sz)) pck_env[$]; //creacion de objeto del tipo transaccion de driver a checker para almacenar el paquete enviado por el driver al DUT
  	trans_driver_checker #(.pckg_sz(pckg_sz)) pck_confirmado[$]; //objeto para poder confirmar 
  	trans_monitor_checker #(.pckg_sz(pckg_sz)) pck_rec[$]; // objeto para almacenar el paquete recibido
  	trans_monitor_checker #(.pckg_sz(pckg_sz)) pck_brdcst[$]; //objeto para almacenar el paquete con broadcast

  	task run();
    	$display("[%0t] El Checker fue inicializado", $time);
        @(flag_end); //
      	begin
          	int cantidad = 0;
         	int pck_recibidos;
          	trans_monitor_checker #(.pckg_sz(pckg_sz)) pck_mntr = new(); //creacion de objeto para almacenar el objeto recibido por el monitor del driver
          	trans_driver_checker #(.pckg_sz(pckg_sz)) pck_driver = new(); // creacion de objeto para almacenar el objeto recibido desde el driver hasta aqui (checker)
          	Trans_resultado #(.pckg_sz(pckg_sz)) resultado =new(); //creacion de objeto para el resultado al realizar comparacion
          	// Ciclo que extrae el paquete del driver
          	while(drvr_chkr_mbx.num()>0)begin 
              	drvr_chkr_mbx.get(pck_driver); 
              	this.pck_env.push_back(pck_driver);
            end
			// Ciclo que extrae el paquete del monitor
          	while(mntr_chkr_mbx.num()>0)begin
              	mntr_chkr_mbx.get(pck_mntr); 
            	this.pck_rec.push_back(pck_mntr);
          	end
         	pck_recibidos = pck_rec.size();
          	//Ciclo para buscar paquete recibido
          	while(cantidad < pck_recibidos)	begin
          		cantidad = cantidad + 1;
            	pck_mntr = pck_rec.pop_front(); // extraccion del paquete proveniente de monitor
              	//Busca dato que se quiere extraer en la cola de paquetes enviados 
              	pck_confirmado = pck_env.find_first(d) with (d.dato == pck_mntr.dato); 
            	foreach(pck_confirmado[n])begin
                  	//En caso de Broadcast
              		if(pck_confirmado[n].brdcst == 1) begin
                      	pck_brdcst = pck_rec.find(d) with (d.dato == pck_mntr.dato);
                      	if(pck_brdcst.size() == drvrs-1)begin 
                        	k = pck_env.find_first_index(j) with (j.dato == pck_mntr.dato);	
                  			foreach(pck_confirmado[n]) begin 
								//Aqui se introduce toda la informacion obtenida en el objeto resultado para imprimirlo
								resultado.disp_origen  = pck_confirmado[n].disp_origen;
  								resultado.destino = pck_confirmado[n].destino;
								resultado.receptor = pck_mntr.receptor;
								resultado.dato_enviado = pck_confirmado[n].dato;
 								resultado.dato_recibido = pck_mntr.dato;
								resultado.t_recepcion = pck_mntr.t_recepcion;
								resultado.t_envio = pck_confirmado[n].t_envio;
								resultado.delay =  pck_mntr.t_recepcion - pck_confirmado[n].t_envio;
                              	delay.push_back(resultado.delay);
								resultado.print("Checker");
							end   
                  			foreach(k[n]) begin           //Utiliza el indice respectivo en el que se esta para eliminar el dato de los paquetes enviados
                      			pck_env.delete(k[n]);	
							end
                        end else begin
                        	$display("[%0t] No se encontró transaccion enviada para el dato entrante:", $time);
							pck_mntr.print("Checker: fallo en el bus en la transaccion ");
                        end
                          
            		end else begin
                  
              		if(pck_confirmado.size() > 0)begin    //Si se obtiene un resultado certero se realiza este proceso
						k = pck_env.find_first_index(j) with (j.dato == pck_mntr.dato);	//busca indice del dato encontrado para eliminarlo de los paquetes enviados 
                  		foreach(pck_confirmado[n]) begin
							//Aqui se introduce toda la informacion obtenida en el objeto resultado para imprimirlo
							resultado.disp_origen  = pck_confirmado[n].disp_origen;
  							resultado.destino = pck_confirmado[n].destino;
							resultado.receptor = pck_mntr.receptor;
							resultado.dato_enviado = pck_confirmado[n].dato;
 							resultado.dato_recibido = pck_mntr.dato;
							resultado.t_recepcion = pck_mntr.t_recepcion;
							resultado.t_envio = pck_confirmado[n].t_envio;
							resultado.delay =  pck_mntr.t_recepcion - pck_confirmado[n].t_envio;
                          	delay.push_back(resultado.delay);
							resultado.print("Resultado Checker");
						end   
                  		foreach(k[n]) begin           //Elimina el dato de la cola con el indice
                      		pck_env.delete(k[n]);	
						end
					end else begin   //Alerta cuando no se encuentra un pck enviado
                      	$display("[%0t] No se encontró transaccion enviada para el dato entrante:", $time);//asignar aserciones
						pck_mntr.print("Reporte de fallo en Checker");
					end
            	end 
          	end
          end
          	if(pck_env.size() > 0) begin  //revisa si un pck enviado no tuvo respuesta 
				$display("[%0t] No hubo respuesta a la siguiente transaccion:",$time);
                foreach(pck_env[n]) begin
                	pck_env[n].print("Reporte de fallo en Checker");     
				end
			end
        end
    endtask
endclass