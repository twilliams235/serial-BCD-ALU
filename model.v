
module combBCDadd_digit (
	input [3:0] A, B,
	input cin,
	output cout,
	output [3:0] F );

    wire [4:0] sum;
    wire [4:0] corrected_sum;
    wire correction_needed;

    assign sum = A + B + cin;
    assign correction_needed = (sum > 9);
    assign corrected_sum = sum + 5'b00110;
    assign F = correction_needed ? corrected_sum[3:0] : sum[3:0];
    assign cout = correction_needed || sum[4];
	
endmodule

module combBCDsub_4d (
  input [3:0] A3, A2, A1, A0,
  input [3:0] B3, B2, B1, B0,
  output [3:0] F4, F3, F2, F1, F0
);

  wire [3:1] carry;
  wire skip;
  reg [3:0] B0_radix, B1_radix, B2_radix, B3_radix;

  
  always @(*) begin
        B0_radix = 4'b1001 - B0;
        B1_radix = 4'b1001 - B1;
        B2_radix = 4'b1001 - B2;
        B3_radix = 4'b1001 - B3;
    end
  
  combBCDadd_digit U0 ( A0, B0_radix,     1'b1, carry[1], F0 );
  combBCDadd_digit U1 ( A1, B1_radix, carry[1], carry[2], F1 );
  combBCDadd_digit U2 ( A2, B2_radix, carry[2], carry[3], F2 );
  combBCDadd_digit U3 ( A3, B3_radix, carry[3],     skip, F3 );

  // carry will never fill 3 MSb of F4
  assign F4[3:0] = 4'b0000;

endmodule

module combBCDadd_4d (
  input  [3:0] A3, A2, A1, A0,
  input  [3:0] B3, B2, B1, B0,
  output [3:0] F4, F3, F2, F1, F0
);

  wire [3:1] carry;

  combBCDadd_digit U0 ( A0, B0,     1'b0, carry[1], F0 );
  combBCDadd_digit U1 ( A1, B1, carry[1], carry[2], F1 );
  combBCDadd_digit U2 ( A2, B2, carry[2], carry[3], F2 );
  combBCDadd_digit U3 ( A3, B3, carry[3],    F4[0], F3 );

  // carry will never fill 3 MSb of F4
  assign F4[3:1] = 3'b000;

endmodule

module Project2 (
	input reset,
	input clock,
	input din,
	output result
);
	reg [40:0] shift_reg;
  	wire [19:0] F_add;
  	wire [19:0] F_minus;
  	reg [27:0] F;
  	reg valid;
  
  	assign result = F[0];
	always @(posedge clock) begin
		if( reset )begin
			shift_reg <= 41'd0;
			F <= 28'd0;
		end
		else begin
			if (valid) begin
				shift_reg <= {din, 40'd0};
				if( shift_reg[8] == 1'b0 ) begin
					F[7:0] <= 8'b01101001;
					F[27:8] <= {F_add[16], F_add[17], F_add[18], F_add[19], F_add[12], F_add[13], F_add[14], F_add[15], F_add[8], 
							F_add[9], F_add[10], F_add[11], F_add[4], F_add[5], F_add[6], F_add[7], F_add[0], F_add[1], F_add[2], 
							F_add[3] };
				end
				else begin
					F[7:0] <= 8'b01101001;
					F[27:8] <= {F_minus[16], F_minus[17], F_minus[18], F_minus[19], F_minus[12], F_minus[13], F_minus[14], 
							F_minus[15], F_minus[8], F_minus[9], F_minus[10], F_minus[11], F_minus[4], F_minus[5], F_minus[6], 
							F_minus[7], F_minus[0], F_minus[1], F_minus[2], F_minus[3] };
				end
			end
			else begin
				shift_reg <= {din, shift_reg[40:1]};			
				F <= { 1'b0, F[27], F[26], F[25], F[24], F[23], F[22], F[21], F[20], F[19], F[18], F[17], F[16], F[15], 
					F[14], F[13], F[12], F[11], F[10], F[9], F[8], F[7], F[6], F[5], F[4], F[3], F[2], F[1] };
			end				
		end	
	end
		
	combBCDadd_4d ADD (
		.A3({shift_reg[9], shift_reg[10], shift_reg[11], shift_reg[12]}),
		.A2({shift_reg[13], shift_reg[14], shift_reg[15], shift_reg[16]}),
		.A1({shift_reg[17], shift_reg[18], shift_reg[19], shift_reg[20]}),
		.A0({shift_reg[21], shift_reg[22], shift_reg[23], shift_reg[24]}),
		.B3({shift_reg[25], shift_reg[26], shift_reg[27], shift_reg[28]}),
		.B2({shift_reg[29], shift_reg[30], shift_reg[31], shift_reg[32]}),
		.B1({shift_reg[33], shift_reg[34], shift_reg[35], shift_reg[36]}),
		.B0({shift_reg[37], shift_reg[38], shift_reg[39], shift_reg[40]}),
		.F4(F_add[3:0]),
		.F3(F_add[7:4]),
		.F2(F_add[11:8]),
		.F1(F_add[15:12]),
		.F0(F_add[19:16])
	);
		
	combBCDsub_4d SUBTRACT (
		.A3({shift_reg[9], shift_reg[10], shift_reg[11], shift_reg[12]}),
		.A2({shift_reg[13], shift_reg[14], shift_reg[15], shift_reg[16]}),
		.A1({shift_reg[17], shift_reg[18], shift_reg[19], shift_reg[20]}),
		.A0({shift_reg[21], shift_reg[22], shift_reg[23], shift_reg[24]}),
		.B3({shift_reg[25], shift_reg[26], shift_reg[27], shift_reg[28]}),
		.B2({shift_reg[29], shift_reg[30], shift_reg[31], shift_reg[32]}),
		.B1({shift_reg[33], shift_reg[34], shift_reg[35], shift_reg[36]}),
		.B0({shift_reg[37], shift_reg[38], shift_reg[39], shift_reg[40]}),
		.F4(F_minus[3:0]),
		.F3(F_minus[7:4]),
		.F2(F_minus[11:8]),
		.F1(F_minus[15:12]),
		.F0(F_minus[19:16])				
	);
	
	always @(*) begin
		if(shift_reg[7:0] == 8'b01011010) valid = 1'b1;
		else valid = 1'b0;
	end
	
	endmodule

