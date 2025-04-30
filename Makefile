VIVADO = /home/cotton/hdd/tools/Xilinx/Vivado/2022.2/bin/vivado

flow :
	rm -rf .srcs *.log *.jou;\
	$(VIVADO) -mode batch -source tcl/flow.tcl  

clean:
	rm -rf post_route synth_tmp .gen .srcs .ip_user_files .Xil *.vcd *.jou *.log a.out