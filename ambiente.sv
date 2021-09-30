// Ambiente


class ambiente #(parameter pckg_sz, parameter drvrs, parameter cola_size, parameter brdcst_ind = {8{1'b1}});
    int csvFile;
    string line;
	//Declaracion de los procesos o modulos hijos
	driver #(.pckg_sz(pckg_sz), .drvrs(drvrs), .cola_size(cola_size)) driver_inst; //declaracion del driver 
	monitor #(.pckg_sz(pckg_sz), .drvrs(drvrs), .cola_size(cola_size)) monitor_inst; // declaracion del monitor
  	agente #(.pckg_sz(pckg_sz), .drvrs(drvrs), .brdcst_ind(brdcst_ind)) agente_inst; // declaracion del agente
	Checker #(.pckg_sz(pckg_sz), .drvrs(drvrs)) checker_inst; // declaracion del checker
	
	//Declaracion de los Mailboxes
	mailbox agent_drvr_mbx;
  	mailbox mntr_chkr_mbx;
  	mailbox driver_chkr_mbx;
	
	//Declaracion 
	event driver_func;
  	event agent_func;

	
	//Declaracion de bus
	virtual bus_if #(.pckg_sz(pckg_sz), .drvrs(drvrs)) _if;
	
	function new();
		//Instanciar Mailbox
		agent_drvr_mbx = new();
		mntr_chkr_mbx = new();
		driver_chkr_mbx = new();
		
		//Instanciar modulos
		driver_inst = new();
		monitor_inst = new();
		agente_inst = new();
		checker_inst = new();
		
		//Conexion de las interfaces y mailboxes
		//Driver
      	driver_inst.vif = _if; 
  		driver_inst.agent_drvr_mbx = agent_drvr_mbx;
		driver_inst.driver_func = driver_func;
      	driver_inst.checker_mbx = driver_chkr_mbx;
		
      	//agente
		agente_inst.agent_drvr_mbx = agent_drvr_mbx;
      	agente_inst.driver_func = driver_func;
      	agente_inst.agent_func = agent_func;
		
      	//Monitor
		monitor_inst.vif = _if;
      	monitor_inst.mntr_chkr_mbx = mntr_chkr_mbx;
		
      	//Checker
		checker_inst.driver_chkr_mbx = driver_chkr_mbx;
      	checker_inst.mntr_chkr_mbx = mntr_chkr_mbx;
      	checker_inst.flag_end = agent_func;
      
	endfunction
	
  	//Inicializa Variables
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