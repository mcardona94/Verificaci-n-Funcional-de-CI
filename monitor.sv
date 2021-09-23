//Monitor


class monitor #(parameter drvrs=4, parameter pckg_sz=16, parameter cola_size = 5);

  	virtual bus_if #(.drvrs(drvrs),.pckg_sz(pckg_sz)) vif; //instancia de la interfaz con el DUT
  	fifo #(.cola_size(cola_size), .pckg_sz(pckg_sz)) fifo_mntr [drvrs-1:0]; // Se instancia el objeto de clase FIFO 
	bit [pckg_sz-9:0] temp; //Variable auxiliar para almacenar el payload
  	mailbox mntr_chkr_mbx = new(drvrs); //instancia del mailbox para comunicarse con el checker
  	
  	task run();
      	$display("[%0t] El monitor fue inicializado", $time);       
    	fork
   		 	begin  
              	for(int i=0; i < drvrs; i++) begin
                  	automatic int idx=i; //variable automatica para iterar dentro de la fifo
          			fifo_mntr [idx] = new();  
            		$display("[%0t] Checker: Transaccion recibida del dispositivo %0d", $time, idx); //Se reporta que se recibio la transaccion
            		fork 
            			begin                                  
              				@(posedge vif.clk);
                			forever begin                 
                              	@(vif.push[0][idx]);                            	
                                fifo_mntr[idx].push(vif.D_push[0][idx]); //Proceso de push 
                            end
                        end
                      	begin
                          	@(posedge vif.clk);
                        	forever begin
                              	//POP
                              	trans_monitor_checker #(.pckg_sz(pckg_sz)) pck = new();
                              	@(posedge vif.clk);
                        		if(fifo_mntr[idx].get_pndg())begin
                                  	temp = fifo_mntr[idx].pop("[MONITOR]"); //Proceso de pop 
                            		pck.dato = temp[pckg_sz-9:0];
                            		pck.t_recepcion = $time; //tiempo que dura recibiendo
                            		pck.receptor = idx; //se le pasa el dato idx al receptor del paquete
                           	 		mntr_chkr_mbx.put(pck); //introduce el paquete al mailbox que conecta con el checker
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