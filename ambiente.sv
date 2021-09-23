// Ambiente


class ambiente #(parameter pckg_sz = 16, parameter drvrs = 4, parameter cola_size = 5, parameter brdcst_ind = {8{1'b1}});
	//Instanciacion de los procesos o modulos hijos que conforman el ambiente
	driver #(.pckg_sz(pckg_sz), .drvrs(drvrs), .cola_size(cola_size)) driver_inst; //Instanciacion del driver 
	monitor #(.pckg_sz(pckg_sz), .drvrs(drvrs), .cola_size(cola_size)) monitor_inst; // Instanciacion del monitor
  	agente #(.pckg_sz(pckg_sz), .drvrs(drvrs), .brdcst_ind(brdcst_ind)) agente_inst; // Instanciacion del agente
	Checker #(.pckg_sz(pckg_sz), .drvrs(drvrs)) checker_inst; // Instanciacion del checker
	
	virtual bus_if #(.pckg_sz(pckg_sz), .drvrs(drvrs)) _if; //Instanciacion de la interfaz del dispositivo bajo prueba
	
	/////Comunicacion entre dispositivos: 
	
	//Creacion de los Mailboxes
	mailbox agent_drvr_mbx; 
  	mailbox mntr_chkr_mbx; //comunicacion entre el monitor y el checker
  	mailbox drvr_chkr_mbx;
	//Creacion de eventos para comunicacion entre dispositivos
	event driver_ready;
  	event agent_done;
	
	function new();
		//Se crean los objetos de tipo mailbox
		agent_drvr_mbx = new();
		mntr_chkr_mbx = new();
		drvr_chkr_mbx = new();
		//Se crean los objetos a partir de las instancias de los respectivos dispositivos
		driver_inst = new();
		monitor_inst = new();
		agente_inst = new();
		checker_inst = new();
		
		//Conexion de las interfaces y mailboxes
		//Driver
      	driver_inst.vif = _if; //conexion del DUT con el dispositivo
  		driver_inst.agent_drvr_mbx = agent_drvr_mbx;
		driver_inst.driver_ready = driver_ready;
      	driver_inst.chkr_mbx = drvr_chkr_mbx;
      	//Agente
		agente_inst.agent_drvr_mbx = agent_drvr_mbx;
      	agente_inst.driver_ready = driver_ready;
      	agente_inst.agent_done = agent_done;
      	//Monitor
		monitor_inst.vif = _if; //conexion del DUT con el dispositivo
      	monitor_inst.mntr_chkr_mbx = mntr_chkr_mbx;
      	//Checker
		checker_inst.drvr_chkr_mbx = drvr_chkr_mbx;
      	checker_inst.mntr_chkr_mbx = mntr_chkr_mbx;
      	checker_inst.flag_end = agent_done;
	endfunction
	
  	//Activa las corridas de los diferentes dispositivos de prueba
	virtual task run();
		$display("[%0t] El ambiente fue inicializado",$time);
		fork
			driver_inst.run();
			monitor_inst.run();
			agente_inst.run();
			checker_inst.run();
		join_none
	endtask
endclass