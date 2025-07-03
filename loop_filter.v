module loop_filter#(parameter width =15)(
    input reset,
    input clk,
    input ted_out_en,
    input signed [31:0]er, // 16.16 format
    output reg signed [31:0]fe, // 16.16 format
    output reg loop_out_en
);



    // PI gains (1.15 format)
    parameter signed [width:0] kp = 16'sd16400;     // 0.5 * 2^15
    parameter signed [width:0] ki = 16'sd1654;      // 0.05 * 2^15


    reg signed [31:0] integrator;  //16.16 format
    reg signed [47:0] p_term; //(16.16) * (1.15) = 17.31 bit format 
    reg signed [47:0] k_term; //(20.16) * (1.15) = 17.31 bit format 


    // FSM
    reg [1:0] state;
    reg level_enable;
    reg [1:0] pulse_counter;

    // per sample output
    reg [4:0] count =0;

    localparam MULTIPLY = 0;
    localparam ADD      = 1;

    always @(posedge clk) begin
        if (reset) begin
            integrator   <= 0;
            p_term       <= 0;
            k_term       <= 0;
            fe           <= 0;
            loop_out_en  <= 0;
            state        <= MULTIPLY;
            level_enable <= 0;
            pulse_counter <= 0;
            count <=0;

        end else begin
            // Pulse latch logic
            if (ted_out_en) begin
                level_enable  <= 1;
                pulse_counter <= 2; // latch for 2 cycles
            end else if (pulse_counter > 0) begin
                pulse_counter <= pulse_counter - 1;   // pulse counter used to latch the ted_out siganl for 2 clock cycles to avoid race condition. 
                if (pulse_counter == 1)              // it should both multiply and add , so happens in two stages. gives 2 clock cycle
                    level_enable <= 0;
            end

            if (level_enable) begin
                case (state)
                    MULTIPLY: begin
                        integrator <= integrator + er;
                        p_term <= kp * er;
                        k_term <= ki * integrator;
                        state <= ADD;
                        loop_out_en <= 0;
                        count <= 19;
                    end

                    ADD: begin
                        fe <= (p_term >>> 16) + (k_term >>> 16); // Q16.16
                        loop_out_en <= 1;
                        state <= MULTIPLY;
                        count <= count -1;
                    end
                endcase
            end
            else if(count ==9)begin
                loop_out_en <=1;
                count <=0;

            end else begin
                loop_out_en <= 0;
                state <= MULTIPLY;
                count <= count - 1;
            end
        end
    end
endmodule
