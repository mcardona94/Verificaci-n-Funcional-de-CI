//Monitor


class monitor #(parameter drvrs=4, parameter pckg_sz=16, parameter cola_size = 5);
	int csvFile;
    string line;
  	//Variables para monitor
  	virtual bus_if #(.drvrs(drvrs),.pckg_sz(pckg_sz)) vif; //Conexion virtual con el DUT
  	fifo #(.cola_size(cola_size), .pckg_sz(pckg_sz)) fifo_out [drvrs-1:0]; // FIFO de recepcion
	bit [pckg_sz-1:0] temp; //variable auxiliar
  	mailbox mntr_chkr_mbx = new(drvrs); //mailbox para almacenar el mensaje proveniente de la transaccion con el checker
  	
  	task run();
      	$display("[%0t] El monitor fue inicializado", $time);       
    	fork
          	//Procesos de FIFO
   		 	begin  
              	for(int i=0; i < drvrs; i++) begin
                  	automatic int idx=i; //variable para asignacion de FIFOs    
          			fifo_out [idx] = new();  
          
            		$display("[%0t] FIFO de salida %0d listo", $time, idx); //mensaje de checkeo  
    
            		fork 
            			begin                                  
              				@(posedge vif.clk);
                			forever begin                 
                              	
                              	@(vif.push[0][idx]);
                              	//PUSH
                        		//if(vif.push[0][idx])begin
                                  	fifo_out[idx].push(vif.D_push[0][idx], "Monitor:");
                        		//end
                            end
                        end
                      	begin
                          	@(posedge vif.clk);
                        	forever begin
                              	//POP
                              	trans_monitor_checker #(.pckg_sz(pckg_sz)) msj = new();
                              	@(posedge vif.clk);
                        		if(fifo_out[idx].get_pndg())begin
                                  	temp = fifo_out[idx].pop("Monitor:");
                            		msj.dato = temp[pckg_sz-9:0];
                            		msj.tiempo_recepcion = $time;
                            		msj.receptor = idx;
                           	 		mntr_chkr_mbx.put(msj);
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