// Interfaz del DUT

interface bus_if #(parameter bits=1,parameter pckg_sz=16, parameter drvrs = 4)(input bit clk);
	logic reset; //señal de reset del dispositivo
  	logic pndng [bits-1:0][drvrs-1:0]; //parametrizacion de buses paralelos (que en este caso es 1) y la cantidad de dispositivos (drivers)
	logic pop [bits-1:0][drvrs-1:0]; //señal de pop
  	logic push [bits-1:0][drvrs-1:0]; //señal de push
	logic [pckg_sz-9:0] D_pop [bits-1:0][drvrs-1:0]; //paquete_inst de salida o dato de salida
  	logic [pckg_sz-9:0] D_push [bits-1:0][drvrs-1:0]; //paquete_inst de entrada o dato de entrada
endinterface