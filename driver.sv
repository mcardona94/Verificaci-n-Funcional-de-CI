// Driver

class driver #(parameter drvrs = 4, parameter pckg_sz = 16, parameter cola_size = 5);
  //Variables Manejo de Driver
  mailbox agent_drvr_mbx;  //Llamado del mailbox para poder comunicarse con el agente
  mailbox chkr_mbx; //Mailbox auxiliar para conectarlo con el del checker
  virtual bus_if #(.drvrs(drvrs),.pckg_sz(pckg_sz)) vif;  //Instanciacion de la interfaz con el DUT
  event driver_ready;  //En este caso se utiliza el mismo evento para reportar que termino de trabajar
  event pck_sent; //Este evento es para indicar que el paquete fue enviado 
  fifo #(.cola_size(cola_size), .pckg_sz(pckg_sz)) cola [drvrs-1:0]; //Se instancia el objeto FIFO asignandole el tamaño de la cola, tamaño del paquete y a la vez generando el arreglo cola 
  //Mailbox auxiliar creado para hacer uso de la FIFO
  mailbox fifo_mbx[drvrs-1:0]; //Mailboxes para pasar datos a los procesos hijos

  task run(); //Inicia ejecucion del proceso padre
    $display("[%0t] El driver fue inicializado", $time);
    for (int i = 0; i < drvrs; i++) begin //Generacion de iteraciones que varian el dispositivo en el mailbox auxiliar de la fifo y los elementos de la cola
      fifo_mbx[i] = new();
      cola[i] = new();
    end
    
    fork
	  // Proceso de envio del paquete del driver a la fifo
      begin
        @(posedge vif.clk);
        forever begin
          paquete #(.pckg_sz(pckg_sz),.drvrs(drvrs)) pck;
                    $display("[%0t] Driver: a la espera de transaccion", $time);
          agent_drvr_mbx.get(pck); // Aqui le pide al mailbox que conecta con el agente que le transmita el paquete
          pck.print_paquete("Driver: Instrucciones del agente: "); //imprime la informacion enviada por el agente para tener una idea de los parametros que va a tener la prueba
          fifo_mbx[pck.disp_origen].put(pck); //Introduce paquete en el mialbox de la FIFO en el slot respectivo al dispositivo en el que se esta en el momento
          @(posedge vif.clk);
            $display("T=%0t Driver: transaccion realizada, paquete enviado la FIFO", $time);
            ->driver_ready; //indica que ya el driver envio el paquete en la FIFO
        end
      end
	  // 
      begin 
        // Proceso de interaccion del driver con el checker
        for (int j = 0; j < drvrs; j++) begin
                    automatic int jj = j; //definicion de variable que se va a sobreescribir automaticamente en cada proceso
          fork		  
            begin
              automatic bit [pckg_sz-9:0] paquete_inst; 
              int delay = 0; //variable almacenar el retardo temporal del proceso 
                            @(posedge vif.clk);
                            forever begin
                                paquete #(.pckg_sz(pckg_sz),.drvrs(drvrs)) pck2; //creacion de objeto de tipo paquete
                                trans_driver_checker #(.pckg_sz(pckg_sz)) pck2_trans = new(); //creacion de objeto de tipo transferencia de driver a checker
                                delay = 0;  
                                @(posedge vif.clk);
                                fifo_mbx[jj].get(pck2); //obtiene dato de la fifo 
                                paquete_inst[pckg_sz-1:pckg_sz-8] = pck2.destino;
                                paquete_inst[pckg_sz-9:0] = pck2.datos;
                				//Ciclo de retraso
                                while(delay <= pck2.retardo_aleatorio)begin
                                  	if(delay >= pck2.retardo_aleatorio)begin
										//se pone en contacto el objeto pck2 generado con el objeto transaccion pck2_trans generado
                                        pck2.print_paquete("Paquete en la FIFO ");
                    					pck2_trans.t_envio = $time;
                                        pck2_trans.destino = pck2.destino;
                                        pck2_trans.dato = pck2.datos;
                                        pck2_trans.disp_origen = pck2.disp_origen;
                    					pck2_trans.brdcst = pck2.bandera_broadcast;
                                        pck2_trans.print("Paquete en el Checker enviado por el driver ");
                                        cola[jj].push(paquete_inst); //se introduce el paquete al arreglo cola
                                        chkr_mbx.put(pck2_trans);
                                        ->pck_sent; //se concluye el evento del envio de paquete iniciado anteriormente
                                        break;  //se genera un break cuando ya se alcanza el tiempo de retardo aleatorio generado
                  					end
                                    @(posedge vif.clk);
                                    delay =  delay + 1; //aumento del tiempo de retardo por ciclo
                				end
                            end
                        end
            
                        begin
                            bit [pckg_sz-9:0] paquete_inst = {pckg_sz-1{1'b0}};
                            @(posedge vif.clk);
                          forever begin
                                @(posedge vif.clk);
                                //Proceso de POP                            
                            	if(vif.pop[0][jj])begin
                              		vif.D_pop[0][jj] = cola[jj].pop("conectada al driver");
                                  	vif.pndng[0][jj] <= cola[jj].get_pndg();
						        end else begin
                                  	vif.D_pop[0][jj] <= cola[jj].cola[$]; 
                                end
                                //Señal de pndng
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
