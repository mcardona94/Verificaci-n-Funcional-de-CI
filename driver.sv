// Driver

class driver #(parameter drvrs = 4, parameter pckg_sz = 16, parameter cola_size = 5);
  //Variables Manejo de Driver
  mailbox driver_agent_amb_mbx;  //Generacion de mailbox para la comunicacion con el agente y el ambiente
  virtual bus_if #(.drvrs(drvrs),.pckg_sz(pckg_sz)) vif;  //Interfase de conexion virtual con el DUT
  event driver_func;  //Evento usado para reportar a otros dispositivos finalizacion de tasks del driver 
  event notificacion_envio;  //Evento para reportar el envio del mensaje al checker 
  int csvFile;
  string line;
  
  //Variables para FIFO
  mailbox fifo_mbx[drvrs-1:0]; //Mailboxes para pasar datos a los procesos hijos
    fifo #(.cola_size(cola_size), .pckg_sz(pckg_sz)) cola [drvrs-1:0]; //Se instancia la clase de fifo 
  bit cmplt;
  
  //Envio a checker
    mailbox checker_mbx;
  
  task run();
        
        $display("[%0t] El driver fue inicializado", $time);
    
        //Inicializacion de mailboxes y FIFOs
    for (int i = 0; i < drvrs; i++) begin 
      fifo_mbx[i] = new();
      cola[i] = new();
    end
    
    fork
      //Proceso de recepcion de mensajes 
      begin
        @(posedge vif.clk);
        forever begin
          mensaje #(.pckg_sz(pckg_sz),.drvrs(drvrs)) msj;
                    $display("[%0t] [Driver] Esperando mensaje...", $time);
          
          //Espera a recibir un mensaje del agente
          driver_agent_amb_mbx.get(msj);
          msj.inf_reporte_consola("Driver"); //Desplega informacion de mensaje
          //Ingresa msj al FIFO
          fifo_mbx[msj.fuente].put(msj);
          @(posedge vif.clk);
            $display("T=%0t [Driver] Mensaje enviado", $time);
            ->driver_func;
        end
      end
      
      //Proceso de los FIFO 
      begin 
        // Generacion de subprocesos
        for (int j = 0; j < drvrs; j++) begin
                    automatic int jj = j;
          fork 
            //Proceso de recepcion de datos del DRIVER
            begin
              automatic bit [pckg_sz-1:0] paquete; //Variable de datos para el fifo
              int delay = 0; //variable para implementar retraso
                            @(posedge vif.clk);
                            forever begin
                                mensaje #(.pckg_sz(pckg_sz),.drvrs(drvrs)) msj2;
                                Trans_driver_chckr #(.pckg_sz(pckg_sz)) msj2chkr = new();
                                delay = 0;  
                              
                                @(posedge vif.clk);
                                fifo_mbx[jj].get(msj2); //toma el dato
                                paquete[pckg_sz-1:pckg_sz-8] = msj2.destino;
                                paquete[pckg_sz-9:0] = msj2.datos;
                              
                				//Ciclo de retraso
                                while(delay <= msj2.tiempo_retardo)begin
                                  	if(delay >= msj2.tiempo_retardo)begin
                                        msj2.inf_reporte_consola("FIFO");
                    					msj2chkr.tiempo_envio = $time;
                                        msj2chkr.destino = msj2.destino;
                                        msj2chkr.dato = msj2.datos;
                                        msj2chkr.fuente = msj2.fuente;
                    					msj2chkr.brdcst = msj2.flg_brdcst;
                                        msj2chkr.reporte_consola("FIFO DRIVER");
                                        cola[jj].push(paquete); //insercion a la cola
                                        checker_mbx.put(msj2chkr);
                                        ->notificacion_envio;
                                        break;  
                  					end
                                    @(posedge vif.clk);
                                    delay =  delay + 1;
                				end
                            end
                        end
            
                        begin
                            bit [pckg_sz-1:0] paquete = {pckg_sz-1{1'b0}};
                            @(posedge vif.clk);
                          forever begin
                            	
                                @(posedge vif.clk);
                                //Manejo de pop                            
                            	if(vif.pop[0][jj])begin
                              		vif.D_pop[0][jj] = cola[jj].pop("INTERFASE DRIVER");
                                  	vif.pndng[0][jj] <= cola[jj].get_pndg();
						        end else begin
                                  	vif.D_pop[0][jj] <= cola[jj].cola[$]; 
                                end
                                //manejo de bandera de pndng
                                if(cola[jj].get_pndg() == 1) begin
                                  	vif.pndng[0][jj] <= 1;
                                end else begin
                                  	vif.pndng[0][jj] <= 0;
                                end
                            
                            end
                        end
                    join_none 
        		end
                wait fork; 
      		end
    	join_any  
  	endtask
endclass
