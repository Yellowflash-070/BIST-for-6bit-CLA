//################################################  Controller  ####################################################

`timescale 1ns/1ps

module CLA_BIST(
    input clk,          // Clock signal
    input rst,          // Reset signal    
    input cin,
    input enl,          // Load signal for LFSR
    input ens,          // Load signal for SISR
    input mode,
    output wire pass     // BIST pass/fail signal
);

reg [3:0] i = 0;
reg [3:0] mem [0:13];
// Declare internal signals
wire cla_cin = 0;
wire enc;
wire mode;
wire [5:0] cla_in1, cla_in2;   // Input to CLA
wire [6:0] cla_sum;  // Sum of CLA (including cout)
wire [3:0] sisr_out; // Output of SISR
wire [3:0] golden_sign;
reg [3:0] gold_sign; // Golden signature value for comparison
// Instantiate components

// LFSR generates pseudo-random test vectors for the CLA adder
lfsr6bit lfsr1(.clk(clk), .rst(rst), .mode(mode), .enl(enl), .out(cla_in1));
lfsr6bit lfsr2(.clk(clk), .rst(rst), .mode(mode), .enl(enl), .out(cla_in2));

// CLA adder adds the inputs and generates sum and carry out
CLA_6bit cla(.mode(mode), .a(cla_in1), .b(cla_in2), .cin(cin), .sum(cla_sum[5:0]), .cout(cla_sum[6]));

// SISR calculates signature based on input data
sisr_4bit_sig sisr(.clk(clk), .rst(rst), .ens(ens), .in(cla_sum), .out(sisr_out), .enc(enc));

// Comparator compares SISR output with golden signature value
comp comparator(.ora(sisr_out), .mode(mode), .enc(enc), .sign(golden_sign), .result(pass));


assign golden_sign = gold_sign;

always@(posedge enc)
begin
    if(i >= 14)
        i = 0;
        
    if(enc && !mode)
        begin
        $display("enc %d",sisr_out);
        mem[i] = sisr_out;
        i = i + 1;
        end
        
     if(mode)
        begin
        gold_sign = mem[i];
        i = i + 1;
        end 
end

endmodule


//################################################  LFSR  ####################################################


// x^6 + x + 1



module lfsr6bit(
    input clk,rst,enl, mode,
    output reg [5:0] out
);
initial out = 6'b111111;
wire tap;

assign tap = out[5]^out[1];

always @(posedge clk, posedge rst)
    begin
        if(rst)
            out <= 6'b111111;
        else if (enl)
            out <= {out[4:0],tap};
        else if(!enl) 
            out <= out;
    end
endmodule


//################################################  CLA 6-bit  ####################################################




module CLA_6bit(

//declaring inputs and outputs
    input [5:0] a,b,
    input cin,
    output [5:0] sum,
    output cout, mode
);

wire [4:0] c;
wire c_temp;
//generation and propagation logic
wire [5:0]gen,prop;

//generate logic
assign gen[0] = a[0] & b[0]; 
assign gen[1] = a[1] & b[1]; 
assign gen[2] = a[2] & b[2]; 
assign gen[3] = a[3] & b[3];
assign gen[4] = a[4] & b[4];
assign gen[5] = a[5] & b[5];

//propagate logic
assign prop[0] = a[0] ^ b[0];
assign prop[1] = a[1] ^ b[1];
assign prop[2] = a[2] ^ b[2];
assign prop[3] = a[3] ^ b[3];
assign prop[4] = a[4] ^ b[4];
assign prop[5] = a[5] ^ b[5];


//combinational logic for carry calculation
assign c[0] = gen[0] + (prop[0] & cin); 
assign c[1] = gen[1] + (prop[1] & c[0]); 
assign c[2] = gen[2] + (prop[2] & c[1]); 
assign c[3] = gen[3] + (prop[3] & c[2]); 
assign c[4] = gen[4] + (prop[4] & c[3]); 
assign c_temp = gen[5] + (prop[5] & c[4]); 
assign cout = mode ? 1'b0 : c_temp;

//combinational logic for sum calculation
assign sum[0] = prop[0] ^ cin;
assign sum[1] = prop[1] ^ c[0];
assign sum[2] = prop[2] ^ c[1];
assign sum[3] = prop[3] ^ c[2];
assign sum[4] = prop[4] ^ c[3];
assign sum[5] = prop[5] ^ c[4];

endmodule


//################################################  SISR  ####################################################


// x^4 + x^3 + 1


module sisr_4bit_sig(
//declaring input/output variables
input clk,rst,ens,
input [6:0] in,
output reg [3:0] out,
output reg enc
);
integer i = 0;
//initializing variables
initial
    begin
        out = 4'b0000;
        enc = 0;
    end
//logic block for updating value of i
always @(posedge clk, posedge rst)
    begin
        if(rst)
            begin
            out <= 4'b0000;
            i <= 0;
            enc <= 0;
            end 
        else if(ens)
            begin
            enc <= 0;
            i <= i + 1;
            end 
        else
            begin
            out <= 4'b0000;
            i <= 0;
            enc <= 0;
            end         
    end
//logic block for signature calculation    
always @(i)
    begin
        if(i<7)
            begin
                $display("current loop# %d",i);
                $display("out value %d",out);
                out[0] <= in[i]^out[3];
                out[1] <= out[0];
                out[2] <= out[1];
                out[3] <= out[2]^out[3];
            end
         else
            begin
            enc <= 1;
            out <= out;
            end     
    end
endmodule


//################################################  Comparator  ####################################################


module comp(
input [3:0] ora, sign, 
input enc, mode, 
output result
);

wire pass;

assign result = (mode & enc) ? (ora === sign) : 1'bz;

endmodule
