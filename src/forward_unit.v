// Coder:           David Adrian Michel Torres, Eduardo Ethandrake Castillo Pulido
// Date:            20/04/23
// File:			     forward_unit.v
// Module name:	  forward_unit
// Project Name:	  risc_v_top
// Description:	  Forwarding unit

module forward_unit (
	//Inputs
	input ex_mem_regWrite, mem_wb_regWrite, ALUSrcB,
	input [4:0] ex_mem_rd, id_ex_reg_rs1, id_ex_reg_rs2, mem_wb_rd,
	//Outputs
	output reg [1:0] forwardA, forwardB, forwardSW
);

//EX Forward Unit
always @(*) begin
	//EX forward unit (forwardA)
	if ((ex_mem_regWrite) && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_reg_rs1)) begin
		forwardA = 2'b10;
	end
	//MEM forward unit (forwardA)
	else if ((mem_wb_regWrite) && (mem_wb_rd != 0) && 
		(ex_mem_rd != id_ex_reg_rs1) && (mem_wb_rd == id_ex_reg_rs1)) begin
		forwardA = 2'b01;
	end
	//Default value
	else begin
		forwardA = 2'b00;
	end
	
	//EX forward unit (forwardB)
	if (~ALUSrcB && (ex_mem_regWrite) && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_reg_rs2)) begin
		forwardB = 2'b10;
	end
	//MEM forward unit (forwardB)
	else if (~ALUSrcB && (mem_wb_regWrite) && (mem_wb_rd != 0) && 
		(ex_mem_rd != id_ex_reg_rs2) && (mem_wb_rd == id_ex_reg_rs2)) begin
		forwardB = 2'b01;
	end
	//Default value
	else begin
		forwardB = 2'b00;
	end
	
	//EX fordward unit (forwardSW)
	if ((ex_mem_regWrite) && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_reg_rs2)) begin
		forwardSW = 2'b10;
	end
	//MEM fordward unit (forwardSW)
	else if ((mem_wb_regWrite) && (mem_wb_rd != 0) && 
		(ex_mem_rd != id_ex_reg_rs2) && (mem_wb_rd == id_ex_reg_rs2)) begin
		forwardSW = 2'b01;
	end
	//Default value
	else begin
		forwardSW = 2'b00;
	end
		
end
	
endmodule