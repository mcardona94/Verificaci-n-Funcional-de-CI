//Checker/scoreboard

class Checker #(parameter drvrs=4, parameter pckg_sz=16);
	// Mailboxes para comunicacion de Checker con otros dispositivos
    mailbox mntr_chkr_mbx;  
    mailbox driver_chkr_mbx;
  	mailbox test_mbx;
    mailbox chkr_sc;
	// Creacion de variable para el archivo .csv
    int csvFile;
    string line;
  
  	event flag_end;	//señal que indica cuando termina el envío de datos (viene de agente)
  	
  	//Instancias de objetos de los tipos de transacciones para verificacion
  	Trans_driver_chckr #(.pckg_sz(pckg_sz)) mensaje_enviado[$];
  	Trans_driver_chckr #(.pckg_sz(pckg_sz)) confirmacion[$];
  	trans_monitor_checker #(.pckg_sz(pckg_sz)) mensaje_recibido[$];
  	trans_monitor_checker #(.pckg_sz(pckg_sz)) mensaje_broadcast[$];
	
	int k[$];
  	int delay[$];
  
  	task run();
    	$display("[%0t] El Checker fue inicializado", $time);
      	
      @(flag_end); //Espera a 
      	begin
          	trans_monitor_checker #(.pckg_sz(pckg_sz)) datos_monitor = new();
          	Trans_driver_chckr #(.pckg_sz(pckg_sz)) datos_driver = new();
          	trans_resultados #(.pckg_sz(pckg_sz)) resultado =new();
            score_board #(.pckg_sz(pckg_sz)) reporte = new();
          	int cantidad = 0;
         	int pcks_recibidos;
          	
          	// Obtiene los mensajes del driver
          	while(driver_chkr_mbx.num()>0)begin 
              	driver_chkr_mbx.get(datos_driver); 
              	this.mensaje_enviado.push_back(datos_driver);
            end
          	
          	// Obtiene los mensajes del monitor
          	while(mntr_chkr_mbx.num()>0)begin
              	mntr_chkr_mbx.get(datos_monitor); 
            	this.mensaje_recibido.push_back(datos_monitor);
          	end


         	pcks_recibidos = mensaje_recibido.size();
			
          	//Ciclo para buscar mensaje recibido en enviados
          	while(cantidad < pcks_recibidos)	begin
          		cantidad = cantidad + 1;
          		
            	datos_monitor = mensaje_recibido.pop_front();
				
              	//Busca dato en cola de msjs enviados
              	confirmacion = mensaje_enviado.find_first(d) with (d.dato == datos_monitor.dato); 
            	
            	foreach(confirmacion[n])begin
                  	
                  	//Manejo de Broadcast
              		if(confirmacion[n].brdcst == 1) begin
                      	mensaje_broadcast = mensaje_recibido.find(d) with (d.dato == datos_monitor.dato);//Busca todos los mensajes con el mismo dato
                      	if(mensaje_broadcast.size() == drvrs-1)begin 
                        	k = mensaje_enviado.find_first_index(j) with (j.dato == datos_monitor.dato);	//busca indice del dato encontrado para eliminarlo
                  			//imprimir mensaje con los datos 
                            reporte.openReport();
                  			foreach(confirmacion[n]) begin
								//Unir datos en una sola estructura con funcion para calcular delay
								resultado.fuente  = confirmacion[n].fuente;
                                reporte.fuente = confirmacion[n].fuente;
  								resultado.destino = confirmacion[n].destino;
                                reporte.destino = confirmacion[n].destino;
								resultado.receptor = datos_monitor.receptor;
                                reporte.receptor = datos_monitor.receptor;
								resultado.dato_enviado = confirmacion[n].dato;
                                reporte.dato_enviado = confirmacion[n].dato;
 								resultado.dato_recibido = datos_monitor.dato;
                                reporte.dato_recibido = datos_monitor.dato;
								resultado.tiempo_recepcion = datos_monitor.tiempo_recepcion;
                                reporte.tiempo_recepcion = datos_monitor.tiempo_recepcion;
								resultado.tiempo_envio = confirmacion[n].tiempo_envio;
                                reporte.tiempo_envio = confirmacion[n].tiempo_envio;
								resultado.delay =  datos_monitor.tiempo_recepcion - confirmacion[n].tiempo_envio;
                                reporte.delay =  datos_monitor.tiempo_recepcion - confirmacion[n].tiempo_envio;
                              	delay.push_back(resultado.delay);
                                delay.push_back(reporte.delay);
								resultado.reporte_consola("Checker:");
                                //reporte.openReport();
                                reporte.writeReport("Se registra transaccion en el Scoreboard: ");
                                //reporte.closeReport();
							end   
                            reporte.closeReport();
                  			foreach(k[n]) begin           //Elimina el dato de la cola con el indice
                      			mensaje_enviado.delete(k[n]);	
							end
                        end else begin
                        	$display("[%0t] No se encontró solicitud de transaccion para el dato entrante:", $time);
							datos_monitor.reporte_consola("Checker: reporte de fallo");
                        end
                          
            		end else begin
                  
              		if(confirmacion.size() > 0)begin    //Si se encontró un dato que coincide
						k = mensaje_enviado.find_first_index(j) with (j.dato == datos_monitor.dato);	//busca indice del dato encontrado para eliminarlo
                  		//imprimir mensaje con los datos 
                        reporte.openReport();
                  		foreach(confirmacion[n]) begin
							//Unir datos en una sola estructura con funcion para calcular delay
								resultado.fuente  = confirmacion[n].fuente;
                                reporte.fuente = confirmacion[n].fuente;
  								resultado.destino = confirmacion[n].destino;
                                reporte.destino = confirmacion[n].destino;
								resultado.receptor = datos_monitor.receptor;
                                reporte.receptor = datos_monitor.receptor;
								resultado.dato_enviado = confirmacion[n].dato;
                                reporte.dato_enviado = confirmacion[n].dato;
 								resultado.dato_recibido = datos_monitor.dato;
                                reporte.dato_recibido = datos_monitor.dato;
								resultado.tiempo_recepcion = datos_monitor.tiempo_recepcion;
                                reporte.tiempo_recepcion = datos_monitor.tiempo_recepcion;
								resultado.tiempo_envio = confirmacion[n].tiempo_envio;
                                reporte.tiempo_envio = confirmacion[n].tiempo_envio;
								resultado.delay =  datos_monitor.tiempo_recepcion - confirmacion[n].tiempo_envio;
                                reporte.delay =  datos_monitor.tiempo_recepcion - confirmacion[n].tiempo_envio;
                              	delay.push_back(resultado.delay);
                                delay.push_back(reporte.delay);
								resultado.reporte_consola("Checker");
                                //reporte.openReport();
                                reporte.writeReport("Se registra transaccion en el Scoreboard: ");
                                //reporte.closeReport();
						end
                        reporte.closeReport();
                  		foreach(k[n]) begin           //Elimina el dato de la cola con el indice
                      		mensaje_enviado.delete(k[n]);	
						end
					end else begin   //Alerta cuando no se encuentra un msj enviado
                      	$display("[%0t] No se encontró transaccion enviada para el dato entrante:", $time);//asignar aserciones
						datos_monitor.reporte_consola("Checker: reporte de fallo");
					end
            	end 
          	end
          end
          	if(mensaje_enviado.size() > 0) begin  //revisa si un msj enviado no tuvo respuesta 
				$display("[%0t] No hubo respuesta a la siguiente transaccion:",$time);
                foreach(mensaje_enviado[n]) begin
                	mensaje_enviado[n].reporte_consola("Checker: reporte de fallo");     
				end
			end
        end
    endtask
endclass