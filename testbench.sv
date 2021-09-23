//Testbench  
`timescale 1ns/100ps
`include "interface.sv"
`include "transactions.sv"
`include "fifoem.sv"
`include "driver.sv"
`include "monitor.sv"
`include "agente.sv"
`include "checker.sv"
`include "ambiente.sv"
`include "test.sv"

         
module tb;
    reg clk; //creacion de la variable de clock
    reg rst; // creacion de la variable de reset
    parameter pckg = 16; //tamaño del paquete_inst de datos
    parameter drvr = 4; // cantidad de dispositivos generados
  	parameter cola = 5; // tamaño de las colas para acumular las transacciones o paquetes generados

    int delay; //variable para delay del test
  	int size; //variable para tamaño del test
  	int retardo_total = 0; //inicializacion de la variable de retardo total del test
    shortreal retardo_promedio; // se inicializa la variable 
  	parameter brdcst_ind = {8{1'b1}}; // Se define el parametro de broadcast de 8 bits

  	always #10 clk =~ clk; //se establece el clock para sincronizar todos los procesos. 
    
  	test #(.pckg_sz(pckg), .drvrs(drvr), .cola_size(cola),.brdcst_ind(brdcst_ind)) t0; //llamado o definicion del modulo de test asignandole parametros
    
    bus_if  #( .drvrs(drvr), .pckg_sz(pckg)) vif (clk); // llamado o bien conexion hacia la interfaz (real) del dispositivo 
  
//// A continuacion se presenta el llamado de la estructura del dispositivo con sus respectivas señales
  bs_gnrtr_n_rbtr #(.drvrs(drvr),.pckg_sz(pckg), .broadcast(brdcst_ind)) DUT(
      .clk(vif.clk),
      .reset(vif.reset),
      .pndng(vif.pndng),
      .push(vif.push),
      .pop(vif.pop),
      .D_pop(vif.D_pop),
      .D_push(vif.D_push)
    );
						   
    initial begin
      	{clk,vif.reset} <= 0; //se le asigna el valor de 0 al clk y al reset de la interfaz 
      	#5
      	vif.reset = 1; // se prende el reset
      	#5
      	vif.reset = 0; // se apaga el reset 
        t0 = new(); //se crea la funcion del test
    	t0._if = vif; 
      	t0.ambiente_inst._if = vif; //aqui se inicializa el proceso hijo del ambiente del dispositivo
        t0.ambiente_inst.driver_inst.vif = vif; //se inicializa el driver que va incluido dentro del ambiente
    	t0.ambiente_inst.monitor_inst.vif = vif; //se inicializa el monitor que va incluido en el ambiente
    	
//////// Por medio del siguiente ciclo se define el dato de salida D_pop y la señal pending en 0 para cada uno de los dispositivos
/// ????? creo que se tiene que quitar		
        for(int k = 0; k<drvr ; k++)begin
          	vif.D_pop[0][k] = 0;
          	vif.pndng[0][k] = 0;
        end
    	$dumpfile("waves.vcd");
        $dumpvars(1, DUT);        
		// se inicializa el test por medio de un proceso hijo con el fork
        fork    
            t0.run(); //test se inicia
        join_none
      	
      	#130000 
      	size = t0.ambiente_inst.checker_inst.delay.size(); //aqui se obtiene el numero de procesos o transacciones del checker
		//se inicializan con valor 0 las variables de retardo promedio y total
        retardo_total = 0; 
        retardo_promedio = 0;
		// se iteran los delays obtenidos del checker para así obtener el retardo total
        for (int i = t0.ambiente_inst.checker_inst.delay.size() ; i > 0; i--)begin
        	delay = t0.ambiente_inst.checker_inst.delay.pop_front();
            retardo_total = retardo_total+delay;
        end
		// se usa el valor del retardo total sumado y se divide entre el size o numero de transacciones
        retardo_promedio = retardo_total / size;
 
      $display("Resultados: ");
      $display("Transacciones realizadas: %g",size); // imprime el valor de la cantidad de transacciones de paquete_insts realizadas
      $display("Tiempo de retardo promedio: %f",retardo_promedio); //imprime el valor del retardo promedio calculado
    end       
    always @(posedge clk) begin
      if($time >  140000) begin //aqui se usa el limitante de tiempo para finalizar el test
          $display("[t=%0t] Test Completado",$time);
          $finish;
        end 
  end
endmodule