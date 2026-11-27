 module memory (Enable,ReadWrite,Address,DataIn,DataOut,clk);
parameter Address_W = 16;
parameter DataIn_W = 32;
input Enable,ReadWrite,clk;
input [DataIn_W-1:0] DataIn; 
input [Address_W-1:0] Address;
output[DataIn_W-1:0] DataOut; 

reg[DataIn_W-1:0]Ram[0:(1<<Address_W)-1];  //every shift is multiply power by 2

always @ (posedge clk) //sync Wrie
begin 
if(Enable && !ReadWrite)
	Ram[Address] <= DataIn;  // non blocking 
end 

assign DataOut = (Enable && ReadWrite) ? Ram[Address] : {DataIn_W{1'bz}}; //tristate buffer

endmodule



