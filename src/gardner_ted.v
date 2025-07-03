module gardner_ted#(parameter width =15)(
    input clk,
    input reset,
    input signed [width:0] I_interp, // 8.8 bit format - 8 bit signed integer (-128 to 127.99)
    input signed [width:0] Q_interp,
    input gardner_en_I,
    input gardner_en_Q,
    output reg signed [31:0]er, //16.16 bit format
    output reg ted_out_en
);

reg [1:0] state =0;
reg signed [width:0]x0,s0; // late
reg signed [width:0]x1,s1; // middle
reg signed [width:0]x2,s2; //early

reg [4:0]count =0 ;

localparam INIT_STAGE = 0;
localparam SAMPLE =1;
localparam SAMPLE_2 =2;
localparam COMPUTE =3;

assign gardner_en = gardner_en_I && gardner_en_Q; // both come at the same time, not an issue.


always@(posedge clk)begin
    if(reset)begin
        er <= 0;
        x0 <= 0;
        x1 <= 0;
        x2 <= 0;
        s0 <= 0;
        s1 <= 0;
        s2 <= 0;
        count <=0;
        state <=0;
        ted_out_en <=0;
    end
    else begin
        case (state)

        INIT_STAGE: begin
            
            ted_out_en <=0; // sampling for initial stage

            if(gardner_en)begin
                s2 <=  I_interp;
                x2 <=Q_interp;
                s1 <= s2;
                x1 <= x2;
                s0 <= s1;
                x0 <= x1; 
            end

            else if(count ==9)begin
                s2 <=  I_interp;
                x2 <= Q_interp;
                s1 <= s2;
                x1 <= x2;
                s0 <= s1;
                x0 <= x1; 
            end

            else if(count ==18)begin
                s2 <=  I_interp;
                x2 <= Q_interp;
                s1 <= s2;
                x1 <= x2;
                s0 <= s1;
                x0 <= x1; 
                state <= COMPUTE;
            end
            
            count <= count +1;
        end

        SAMPLE: begin
            count <= count +1;
            ted_out_en <=0;

            if(count ==10)begin
                s2 <= I_interp;
                x2 <= Q_interp;
                s1 <= s2;
                x1 <= x2;
                s0 <= s1;
                x0 <= x1; 
                state <=SAMPLE_2;
                count <=1;
            end
           
        end
        SAMPLE_2: begin
            count <= count +1;
            ted_out_en <=0;

            if(count ==10)begin
                s2 <= I_interp;
                x2 <= Q_interp;
                s1 <= s2;
                x1 <= x2;
                s0 <= s1;
                x0 <= x1; 
                state <=COMPUTE;
                
            end
        end


        COMPUTE: begin
            er <= s1*(s2-s0) + x1*(x2-x0); //16.16 bit format
            count <=2;
            state <= SAMPLE;
            ted_out_en <=1;

        end
        endcase
    end
end

endmodule
