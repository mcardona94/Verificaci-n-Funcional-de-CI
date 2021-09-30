// Test   *le faltan pruebas          
              
class test #(parameter pckg_sz = 16, parameter drvrs = 4, parameter cola_size = 5, parameter brdcst_ind = {8{1'b1}});
  int csvFile;
  string line;
  //function void openReport();
    //csvFile = $fopen ("./Reporte.csv", "w");
  //endfunction  
  
//  function void closeReport();
//   $fclose(csvFile);
//  endfunction
  	ambiente #(.pckg_sz(pckg_sz), .drvrs(drvrs), .cola_size(cola_size),.brdcst_ind(brdcst_ind)) ambiente_inst; //se crea el ambiente con sus respectivos parametros
  	
  	virtual bus_if #(.pckg_sz(pckg_sz), .drvrs(drvrs)) _if; //aqui se crea la interfaz virtual con el DUT o bien se conecta de forma virtual con el DUT
	
  	function new;
    	ambiente_inst = new(); //se crea el objeto del ambiente ambiente_inst
    	ambiente_inst._if = _if; //se conecta el ambiente con el dispositivo
  	endfunction
  // Aqui se inicializa el funcionamiento del test que lo que va a hacer es activar el funcionamiento del ambiente
  	task run;
		$display("[%g]  El Test fue inicializado",$time);
    	fork 
      		ambiente_inst.run();
    	join_none
    	#140000
    	$display("[%g] Test: Se alcanza el tiempo limite", $time);
    	#20
    	$finish;
  	endtask
endclass              