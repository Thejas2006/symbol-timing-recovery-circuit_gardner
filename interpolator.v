
module interpolator    (
   input  wire signed [15:0]   data_in , // 8.8 bit format
   input  wire                 interpolator_en   ,  //strobe
   input  wire                 clk     ,
   input  wire                 rst_n   ,
   input             [15:0] f, // aka u_k (1.15 bit format)
   input  signed  [15:0] m_k,
   output reg                  data_out_en,
   output reg   signed  [15:0] data_out    //8.8 bit format  
);

//Interpolator redefines new samples based on previous samples and fractional delay from NCO
	          
			            
reg signed [15:0] tap[9:0] ; //1.15 bit format
reg  signed [15:0] buffer[9:0];
reg signed  [31:0] accumulator[9:0] ; // 9.23 bit format

wire data_en_w;

reg gardner_en =1;

reg signed[31:0] temp_data_out; //9.23 bit format
reg [4:0] count;
reg [4:0]accum_counter = 0;
reg signed [31:0] test ;
reg [1:0] pulse_counter = 0;
reg interpolator_en_latched = 0;
reg [2:0] state =0;
						
                        
	                    
	                    
	                    
	    ///////////////////filter taps assignments /////////////////
always@(posedge clk or negedge rst_n) begin
if(!rst_n) begin
 tap[0]= 16'd0;
 tap[1]=  16'd0;
 tap[2]=  16'd0;
 tap[3]=  16'd0;
 tap[4]=  16'd0;
 tap[5]=  16'd0;
 tap[6]=  16'd0;
 tap[7]=  16'd0;
 tap[8]=  16'd0;
 tap[9]=  16'd0;

end 
else begin
if(f >= 16'd0 && f < 16'd328) begin
 tap[0] = 16'd6;
tap[1] = -16'd29;
tap[2] = 16'd91;
tap[3] = -16'd268;
tap[4] = 16'd32732;
tap[5] = 16'd331;
tap[6] = -16'd137;
tap[7] = 16'd62;
tap[8] = -16'd23;
tap[9] = 16'd3;
end
 else if(f > 16'd328 && f<16'd655) begin
 //f = 0.02;
//f_scaled = 16'd655;
//Scaled Coefficients (rounded to whole numbers):
tap[0] = 16'd13;
tap[1] = -16'd59;
tap[2] = 16'd180;
tap[3] = -16'd530;
tap[4] = 16'd32689;
tap[5] = 16'd668;
tap[6] = -16'd275;
tap[7] = 16'd121;
tap[8] = -16'd46;
tap[9] = 16'd10;
end 
else if(f > 16'd655 &&  f< 16'd983) begin
tap[0] = 16'd19;
tap[1] = -16'd88;
tap[2] = 16'd268;
tap[3] = -16'd790;
tap[4] = 16'd32633;
tap[5] = 16'd1009;
tap[6] = -16'd413;
tap[7] = 16'd183;
tap[8] = -16'd69;
tap[9] = 16'd13;
end
else if(f > 16'd983 && f<16'd1311)  begin
tap[0] = 16'd23;
tap[1] = -16'd118;
tap[2] = 16'd354;
tap[3] = -16'd1038;
tap[4] = 16'd32568;
tap[5] = 16'd1356;
tap[6] = -16'd550;
tap[7] = 16'd245;
tap[8] = -16'd91;
tap[9] = 16'd19;
end
else if(f >16'd1311 && f<16'd1638) begin
tap[0] = 16'd29;
tap[1] = -16'd147;
tap[2] = 16'd439;
tap[3] = -16'd1284;
tap[4] = 16'd32492;
tap[5] = 16'd1710;
tap[6] = -16'd691;
tap[7] = 16'd304;
tap[8] = -16'd114;
tap[9] = 16'd23;
end
else if(f >16'd1638 && f<16'd1966) begin
tap[0] = 16'd36;
tap[1] = -16'd177;
tap[2] = 16'd524;
tap[3] = -16'd1523;
tap[4] = 16'd32407;
tap[5] = 16'd2067;
tap[6] = -16'd832;
tap[7] = 16'd367;
tap[8] = -16'd137;
tap[9] = 16'd29;
end

else if(f > 16'd1966 && f<16'd2294) begin
//f = 0.07;
//f_scaled = 16'd2294;
//Scaled Coefficients (rounded to whole numbers):
tap[0] = 16'd43;
tap[1] = -16'd203;
tap[2] = 16'd607;
tap[3] = -16'd1754;
tap[4] = 16'd32314;
tap[5] = 16'd2433;
tap[6] = -16'd973;
tap[7] = 16'd429;
tap[8] = -16'd161;
tap[9] = 16'd33;
end  
else if(f > 16'd2294 && f<16'd2621) begin
//f = 0.08;
tap[0] = 16'd46;
tap[1] = -16'd233;
tap[2] = 16'd688;
tap[3] = -16'd1978;
tap[4] = 16'd32192;
tap[5] = 16'd2802;
tap[6] = -16'd1114;
tap[7] = 16'd492;
tap[8] = -16'd184;
tap[9] = 16'd39;
end
else if(f >16'd2621 && f<16'd2949) begin
///f = 0.09;
tap[0] = 16'd52;
tap[1] = -16'd259;
tap[2] = 16'd769;
tap[3] = -16'd2198;
tap[4] = 16'd32061;
tap[5] = 16'd3175;
tap[6] = -16'd1255;
tap[7] = 16'd551;
tap[8] = -16'd203;
tap[9] = 16'd43;
end   
else if(f >16'd2949 &&f<16'd3277) begin
///f = 0.10;
tap[0] = 16'd59;
tap[1] = -16'd285;
tap[2] = 16'd845;
tap[3] = -16'd2411;
tap[4] = 16'd31926;
tap[5] = 16'd3551;
tap[6] = -16'd1396;
tap[7] = 16'd612;
tap[8] = -16'd227;
tap[9] = 16'd49;
end
else if(f >16'd3277 &&f<16'd3604) begin
//f = 0.11;
tap[0] = 16'd62;
tap[1] = -16'd311;
tap[2] = 16'd924;
tap[3] = -16'd2619;
tap[4] = 16'd31819;
tap[5] = 16'd3932;
tap[6] = -16'd1537;
tap[7] = 16'd675;
tap[8] = -16'd248;
tap[9] = 16'd52;
end
else if(f >16'd3604 && f<16'd3932) begin
//f = 0.12;
tap[0] = 16'd69;
tap[1] = -16'd338;
tap[2] = 16'd996;
tap[3] = -16'd2816;
tap[4] = 16'd31696;
tap[5] = 16'd4320;
tap[6] = -16'd1678;
tap[7] = 16'd733;
tap[8] = -16'd271;
tap[9] = 16'd59;
end
else if(f >16'd3932 &&f<16'd4260) begin
//f = 0.13;
tap[0] = 16'd75;
tap[1] = -16'd364;
tap[2] = 16'd1073;
tap[3] = -16'd3012;
tap[4] = 16'd31565;
tap[5] = 16'd4711;
tap[6] = -16'd1819;
tap[7] = 16'd792;
tap[8] = -16'd295;
tap[9] = 16'd62;
end
else if(f > 16'd4260 && f<16'd4588) begin
//f = 0.14;
tap[0] = 16'd78;
tap[1] = -16'd386;
tap[2] = 16'd1140;
tap[3] = -16'd3198;
tap[4] = 16'd31428;
tap[5] = 16'd5104;
tap[6] = -16'd1961;
tap[7] = 16'd855;
tap[8] = -16'd315;
tap[9] = 16'd69;
end
else if(f >16'd4588 &&f<16'd4915) begin
//f = 0.15;
tap[0] = 16'd85;
tap[1] = -16'd413;
tap[2] = 16'd1208;
tap[3] = -16'd3379;
tap[4] = 16'd31217;
tap[5] = 16'd5511;
tap[6] = -16'd2100;
tap[7] = 16'd914;
tap[8] = -16'd337;
tap[9] = 16'd73;
end
else if (f >16'd4915  && f < 16'd5243)
 begin
//f = 0.16;
tap[0] = 16'd88;
tap[1] = -16'd435;//-131
tap[2] = 16'd1271;//357.17
tap[3] = -16'd3556;//-793
tap[4] = 16'd31014;//1651.5
tap[5] = 16'd5901;//-3844
tap[6] = -16'd2235;//31198
tap[7] = 16'd974;//5898
tap[8] = -16'd357;//-2418
tap[9] = 16'd75;//1255
end
else if(f >16'd5243 && f<16'd5571) begin
//f = 0.17;
tap[0] = 16'd95;
tap[1] = -16'd459;
tap[2] = 16'd1342;
tap[3] = -16'd3715;
tap[4] = 16'd30879;
tap[5] = 16'd6306;
tap[6] = -16'd2372;
tap[7] = 16'd1027;
tap[8] = -16'd380;
tap[9] = 16'd32;
end
else if(f >16'd5571 && f<16'd5898) begin
//f = 0.18;
tap[0] = 16'd98;
tap[1] = -16'd482;
tap[2] = 16'd1405;
tap[3] = -16'd3874;
tap[4] = 16'd30558;
tap[5] = 16'd6715;
tap[6] = -16'd2511;
tap[7] = 16'd1086;
tap[8] = -16'd399;
tap[9] = 16'd85;
end
else if(f >16'd5898 && f<16'd6226) begin
//f = 0.19;
tap[0] = 16'd105;
tap[1] = -16'd501;
tap[2] = 16'd1468;
tap[3] = -16'd4028;
tap[4] = 16'd30442;
tap[5] = 16'd7141;
tap[6] = -16'd2648;
tap[7] = 16'd1143;
tap[8] = -16'd419;
tap[9] = 16'd88;
end
else if(f >16'd6226 && f<16'd6554) begin
//f = 0.20;
tap[0] = 16'd108;
tap[1] = -16'd524;
tap[2] = 16'd1523;
tap[3] = -16'd4177;
tap[4] = 16'd30130;
tap[5] = 16'd7567;
tap[6] = -16'd2786;
tap[7] = 16'd1190;
tap[8] = -16'd438;
tap[9] = 16'd95;
end
else if(f >16'd6554 && f<16'd6881) begin
//f = 0.21;
tap[0] = 16'd111;
tap[1] = -16'd542;
tap[2] = 16'd1583;
tap[3] = -16'd4312;
tap[4] = 16'd29956;
tap[5] = 16'd7961;
tap[6] = -16'd2915;
tap[7] = 16'd1253;
tap[8] = -16'd459;
tap[9] = 16'd98;
end
else if(f >16'd6881 && f<16'd7209) begin
//f = 0.22;
tap[0] = 16'd115;
tap[1] = -16'd563;
tap[2] = 16'd16384;
tap[3] = -16'd4454;
tap[4] = 16'd29759;
tap[5] = 16'd8385;
tap[6] = -16'd3045;
tap[7] = 16'd1311;
tap[8] = -16'd479;
tap[9] = 16'd102;
end

else if( f >16'd7209 && f<16'd7537) begin
//f = 0.23;
//f_scaled = 16'd7537;
//Scaled Coefficients (rounded to whole numbers):
tap[0] = 16'd122;
tap[1] = -16'd583;
tap[2] = 16'd1694;
tap[3] = -16'd4575;
tap[4] = 16'd29543;
tap[5] = 16'd8805;
tap[6] = -16'd3175;
tap[7] = 16'd1365;
tap[8] = -16'd499;
tap[9] = 16'd108;
end

else if(f >16'd7537 && f<16'd7864) begin
//f = 0.24;
//f_scaled = 16'd7864;
//Scaled Coefficients (rounded to whole numbers):
tap[0] = 16'd124;
tap[1] = -16'd599;
tap[2] = 16'd1749;
tap[3] = -16'd4698;
tap[4] = 16'd29266;
tap[5] = 16'd9231;
tap[6] = -16'd3316;
tap[7] = 16'd1411;
tap[8] = -16'd517;
tap[9] = 16'd111;
end

else if(f >16'd7864 && f<16'd8192) begin
//f = 0.25;
//f_scaled = 16'd8192;
//Scaled Coefficients (rounded to whole numbers):
tap[0] = 16'd127;
tap[1] = -16'd620;
tap[2] = 16'd1794;
tap[3] = -16'd4820;
tap[4] = 16'd29091;
tap[5] = 16'd9675;
tap[6] = -16'd3435;
tap[7] = 16'd1464;
tap[8] = -16'd533;
tap[9] = 16'd115;
end
else if(f >16'd8192 && f<16'd8520) begin
//f = 0.26;
//f_scaled = 16'd8520;
//Scaled Coefficients (rounded to whole numbers):
tap[0] = 16'd131;
tap[1] = -16'd636;
tap[2] = 16'd1835;
tap[3] = -16'd4921;
tap[4] = 16'd28761;
tap[5] = 16'd10109;
tap[6] = -16'd3560;
tap[7] = 16'd1515;
tap[8] = -16'd554;
tap[9] = 16'd98;
end

else if(f >16'd8520 && f<16'd8847) begin
//f = 0.27;
//f_scaled = 16'd8847;
//Scaled Coefficients (rounded to whole numbers):
tap[0] = 16'd134;
tap[1] = -16'd652;
tap[2] = 16'd1884;
tap[3] = -16'd5019;
tap[4] = 16'd28462;
tap[5] = 16'd10536;
tap[6] = -16'd3684;
tap[7] = 16'd1565;
tap[8] = -16'd570;
tap[9] = 16'd121;
end

else if(f >16'd8847 && f<16'd9175) begin
//f = 0.28;
//f_scaled = 16'd9175;
//Scaled Coefficients (rounded to whole numbers):
tap[0] = 16'd138;
tap[1] = -16'd665;
tap[2] = 16'd1923;
tap[3] = -16'd5111;
tap[4] = 16'd28166;
tap[5] = 16'd10960;
tap[6] = -16'd3805;
tap[7] = 16'd1612;
tap[8] = -16'd586;
tap[9] = 16'd125;
end

else if(f >16'd9175 && f<16'd9503) begin
//f = 0.29;
//f_scaled = 16'd9503;
//Scaled Coefficients (rounded to whole numbers):
tap[0] = 16'd141;
tap[1] = -16'd682;
tap[2] = 16'd1963;
tap[3] = -16'd5204;
tap[4] = 16'd27867;
tap[5] = 16'd11388;
tap[6] = -16'd3924;
tap[7] = 16'd1660;
tap[8] = -16'd603;
tap[9] = 16'd128;
end

else if(f >16'd9503 && f<16'd9830) begin
//f = 0.30;
//f_scaled = 16'd9830;
//Scaled Coefficients (rounded to whole numbers):
tap[0] = 16'd144;
tap[1] = -16'd695;
tap[2] = 16'd2002;
tap[3] = -16'd5282;
tap[4] = 16'd27585;
tap[5] = 16'd11827;
tap[6] = -16'd4037;
tap[7] = 16'd1705;
tap[8] = -16'd619;
tap[9] = 16'd131;
end
else if(f > 16'd9830 && f<16'd10158) begin
//f = 0.31;
//f_scaled = 16'd10158;
//Scaled Coefficients (rounded to whole numbers):
tap[0] = 16'd147;
tap[1] = -16'd707;
tap[2] = 16'd2038;
tap[3] = -16'd5359;
tap[4] = 16'd27288;
tap[5] = 16'd12260;
tap[6] = -16'd4154;
tap[7] = 16'd1749;
tap[8] = -16'd635;
tap[9] = 16'd134;
end

else if( f >16'd10158 && f<16'd10486) begin
//f = 0.32;
//f_scaled = 16'd10486;
//Scaled Coefficients (rounded to whole numbers):
tap[0] = 16'd151;
tap[1] = -16'd721;
tap[2] = 16'd2069;
tap[3] = -16'd5429;
tap[4] = 16'd26978;
tap[5] = 16'd12691;
tap[6] = -16'd4265;
tap[7] = 16'd1793;
tap[8] = -16'd649;
tap[9] = 16'd138;
end

else if(f >16'd10486 && f<16'd10813) begin
//f = 0.33;
//f_scaled = 16'd10813;
//Scaled Coefficients (rounded to whole numbers):
tap[0] = 16'd151;
tap[1] = -16'd730;
tap[2] = 16'd2099;
tap[3] = -16'd5489;
tap[4] = 16'd26666;
tap[5] = 16'd13119;
tap[6] = -16'd4372;
tap[7] = 16'd1830;
tap[8] = -16'd665;
tap[9] = 16'd141;
end

else if(f >16'd10813 && f<16'd11141) begin
//f = 0.34;
//f_scaled = 16'd11141;
//Scaled Coefficients (rounded to whole numbers):
tap[0] = 16'd154;
tap[1] = -16'd743;
tap[2] = 16'd2126;
tap[3] = -16'd5545;
tap[4] = 16'd26352;
tap[5] = 16'd13557;
tap[6] = -16'd4475;
tap[7] = 16'd1869;
tap[8] = -16'd678;
tap[9] = 16'd144;
end

else if(f >16'd11141 && f<16'd11469) begin
//f = 0.35;
//f_scaled = 16'd11469;
//Scaled Coefficients (rounded to whole numbers):
tap[0] = 16'd157;
tap[1] = -16'd753;
tap[2] = 16'd2151;
tap[3] = -16'd5597;
tap[4] = 16'd26036;
tap[5] = 16'd13997;
tap[6] = -16'd4577;
tap[7] = 16'd1908;
tap[8] = -16'd692;
tap[9] = 16'd147;
end

else if(f >16'd11469 && f<16'd11796) begin
//f = 0.36;
//f_scaled = 16'd11796;
//Scaled Coefficients (rounded to whole numbers):
tap[0] = 16'd157;
tap[1] = -16'd760;
tap[2] = 16'd2179;
tap[3] = -16'd5637;
tap[4] = 16'd25678;
tap[5] = 16'd14436;
tap[6] = -16'd4675;
tap[7] = 16'd1948;
tap[8] = -16'd705;
tap[9] = 16'd151;
end

else if(f >16'd11796 && f<16'd12124) begin
//f = 0.37;
//f_scaled = 16'd12124;
//Scaled Coefficients (rounded to whole numbers):
tap[0] = 16'd161;
tap[1] = -16'd771;
tap[2] = 16'd2200;
tap[3] = -16'd5676;
tap[4] = 16'd25342;
tap[5] = 16'd14873;
tap[6] = -16'd4772;
tap[7] = 16'd1982;
tap[8] = -16'd715;
tap[9] = 16'd151;
end
else if(f >16'd12124 && f<16'd12452) begin
//f = 0.38;
tap[0] = 16'd164;
tap[1] = -16'd777;
tap[2] = 16'd2219;
tap[3] = -16'd5706;
tap[4] = 16'd24996;
tap[5] = 16'd15311;
tap[6] = -16'd4862;
tap[7] = 16'd2015;
tap[8] = -16'd727;
tap[9] = 16'd154;
end
else if(f >16'd12452 && f<16'd12780) begin
//f = 0.39;
tap[0] = 16'd164;
tap[1] = -16'd784;
tap[2] = 16'd2235;
tap[3] = -16'd5734;
tap[4] = 16'd24647;
tap[5] = 16'd15738;
tap[6] = -16'd4950;
tap[7] = 16'd2043;
tap[8] = -16'd737;
tap[9] = 16'd157;
end
else if(f >16'd12780 && f<16'd13107) begin
//f = 0.40;

tap[0] = 16'd164;
tap[1] = -16'd790;
tap[2] = 16'd2248;
tap[3] = -16'd5753;
tap[4] = 16'd24297;
tap[5] = 16'd16166;
tap[6] = -16'd5032;
tap[7] = 16'd2077;
tap[8] = -16'd747;
tap[9] = 16'd157;
end
else if(f >16'd13107 && f<16'd13435) begin
//f = 0.41;
tap[0] = 16'd167;
tap[1] = -16'd796;
tap[2] = 16'd2261;
tap[3] = -16'd5768;
tap[4] = 16'd23845;
tap[5] = 16'd16600;
tap[6] = -16'd5116;
tap[7] = 16'd2104;
tap[8] = -16'd757;
tap[9] = 16'd161;
end
else if(f >16'd13435 && f<16'd13763) begin
//f = 0.42;
tap[0] = 16'd167;
tap[1] = -16'd800;
tap[2] = 16'd2270;
tap[3] = -16'd5777;
tap[4] = 16'd23562;
tap[5] = 16'd17039;
tap[6] = -16'd5187;
tap[7] = 16'd2131;
tap[8] = -16'd763;
tap[9] = 16'd161;
end
else if(f >16'd13763 && f<16'd14090) begin
//f = 0.43;
tap[0] = 16'd167;
tap[1] = -16'd803;
tap[2] = 16'd2276;
tap[3] = -16'd5777;
tap[4] = 16'd23159;
tap[5] = 16'd17478;
tap[6] = -16'd5257;
tap[7] = 16'd2154;
tap[8] = -16'd772;
tap[9] = 16'd164;
end  
else if(f >16'd14090 && f<16'd14418) begin
//////f = 0.44;
tap[0] = 16'd170;
tap[1] = -16'd807;
tap[2] = 16'd2283;
tap[3] = -16'd5774;
tap[4] = 16'd22815;
tap[5] = 16'd17917;
tap[6] = -16'd5328;
tap[7] = 16'd2176;
tap[8] = -16'd779;
tap[9] = 16'd164;
end
else if(f >16'd14418 && f<16'd14746) begin
//f = 0.45;
tap[0] = 16'd170;
tap[1] = -16'd811;
tap[2] = 16'd2287;
tap[3] = -16'd5768;
tap[4] = 16'd22472;
tap[5] = 16'd18355;
tap[6] = -16'd5394;
tap[7] = 16'd2195;
tap[8] = -16'd786;
tap[9] = 16'd167;
end
else if(f >16'd14746 && f<16'd15073) begin
//f = 0.46;
tap[0] = 16'd170;
tap[1] = -16'd811;
tap[2] = 16'd2287;
tap[3] = -16'd5744;
tap[4] = 16'd22001;
tap[5] = 16'd18735;
tap[6] = -16'd5450;
tap[7] = 16'd2214;
tap[8] = -16'd794;
tap[9] = 16'd167;
end
else if(f >16'd15073 && f<16'd15401) begin
//f = 0.47;
tap[0] = 16'd170;
tap[1] = -16'd811;
tap[2] = 16'd2283;
tap[3] = -16'd5725;
tap[4] = 16'd21607;
tap[5] = 16'd19147;
tap[6] = -16'd5505;
tap[7] = 16'd2231;
tap[8] = -16'd798;
tap[9] = 16'd167;
end
else if(f >16'd15401<f<16'd15729) begin
//f = 0.48;
tap[0] = 16'd170;
tap[1] = -16'd811;
tap[2] = 16'd2280;
tap[3] = -16'd5702;
tap[4] = 16'd21214;
tap[5] = 16'd19560;
tap[6] = -16'd5555;
tap[7] = 16'd2244;
tap[8] = -16'd800;
tap[9] = 16'd167;
end
else if(f >16'd15729 && f<16'd16056) begin
//f = 0.49;
tap[0] = 16'd170;
tap[1] = -16'd811;
tap[2] = 16'd2277;
tap[3] = -16'd5669;
tap[4] = 16'd20816;
tap[5] = 16'd19972;
tap[6] = -16'd5602;
tap[7] = 16'd2257;
tap[8] = -16'd804;
tap[9] = 16'd170;
end
else if(f >16'd16056 && f<16'd16384) begin
//f = 0.50;
tap[0] = 16'd170;
tap[1] = -16'd807;
tap[2] = 16'd2261;
tap[3] = -16'd5636;
tap[4] = 16'd20419;
tap[5] = 16'd20419;
tap[6] = -16'd5636;
tap[7] = 16'd2261;
tap[8] = -16'd807;
tap[9] = 16'd170;
end
else if(f >16'd16384 && f<16'd16712) begin
//f = 0.51;
tap[0] = 16'd170;
tap[1] = -16'd802;
tap[2] = 16'd2258;
tap[3] = -16'd5602;
tap[4] = 16'd19972;
tap[5] = 16'd20816;
tap[6] = -16'd5669;
tap[7] = 16'd2277;
tap[8] = -16'd810;
tap[9] = 16'd170;
end
else if(f >16'd16712 && f<16'd17039) begin
//f = 0.52;
tap[0] = 16'd167;
tap[1] = -16'd800;
tap[2] = 16'd2244;
tap[3] = -16'd5555;
tap[4] = 16'd19560;
tap[5] = 16'd21214;
tap[6] = -16'd5702;
tap[7] = 16'd2280;
tap[8] = -16'd810;
tap[9] = 16'd170;
end
else if(f > 16'd17039<f<16'd17367) begin
//f = 0.53;
tap[0] = 16'd167;
tap[1] = -16'd797;
tap[2] = 16'd2231;
tap[3] = -16'd5505;
tap[4] = 16'd19147;
tap[5] = 16'd21607;
tap[6] = -16'd5725;
tap[7] = 16'd2283;
tap[8] = -16'd810;
tap[9] = 16'd170;
end
else if(f >16'd17367 && f<16'd17695) begin
//f = 0.54;
tap[0] = 16'd167;
tap[1] = -16'd794;
tap[2] = 16'd2214;
tap[3] = -16'd5450;
tap[4] = 16'd18735;
tap[5] = 16'd22001;
tap[6] = -16'd5744;
tap[7] = 16'd2287;
tap[8] = -16'd810;
tap[9] = 16'd170;
end
else if(f >16'd17695 && f<16'd18022) begin
//f = 0.55;
tap[0] = 16'd167;
tap[1] = -16'd786;
tap[2] = 16'd2195;
tap[3] = -16'd5387;
tap[4] = 16'd18315;
tap[5] = 16'd22394;
tap[6] = -16'd5767;
tap[7] = 16'd2287;
tap[8] = -16'd810;
tap[9] = 16'd170;
end    
else if(f >16'd18022 && f<16'd18350) begin
//f = 0.56;
tap[0] = 16'd164;
tap[1] = -16'd779;
tap[2] = 16'd2176;
tap[3] = -16'd5328;
tap[4] = 16'd17901;
tap[5] = 16'd22788;
tap[6] = -16'd5774;
tap[7] = 16'd2283;
tap[8] = -16'd807;
tap[9] = 16'd170;
end
else if(f >16'd18350 && f<16'd18678) begin
//f = 0.57;
tap[0] = 16'd164;
tap[1] = -16'd772;
tap[2] = 16'd2151;
tap[3] = -16'd5260;
tap[4] = 16'd17487;
tap[5] = 16'd23181;
tap[6] = -16'd5777;
tap[7] = 16'd2277;
tap[8] = -16'd802;
tap[9] = 16'd167;
end
else if(f >16'd18678 && f<16'd19005) begin
//f = 0.58;
tap[0] = 16'd161;
tap[1] = -16'd762;
tap[2] = 16'd2131;
tap[3] = -16'd5189;
tap[4] = 16'd17040;
tap[5] = 16'd23575;
tap[6] = -16'd5777;
tap[7] = 16'd2270;
tap[8] = -16'd797;
tap[9] = 16'd167;
end
else if(f >16'd19005 && f<16'd19333) begin
//f = 0.59;
tap[0] = 16'd161;
tap[1] = -16'd755;
tap[2] = 16'd2103;
tap[3] = -16'd5114;
tap[4] = 16'd16598;
tap[5] = 16'd23968;
tap[6] = -16'd5767;
tap[7] = 16'd2260;
tap[8] = -16'd794;
tap[9] = 16'd167;
end
else if(f >16'd19333 && f<16'd19661) begin
//f = 0.60;
tap[0] = 16'd157;
tap[1] = -16'd747;
tap[2] = 16'd2077;
tap[3] = -16'd5028;
tap[4] = 16'd16156;
tap[5] = 16'd24361;
tap[6] = -16'd5754;
tap[7] = 16'd2244;
tap[8] = -16'd789;
tap[9] = 16'd164;
end
else if(f >16'd19661 && f<16'd19988) begin//
//f = 0.61;
tap[0] = 16'd157;
tap[1] = -16'd737;
tap[2] = 16'd2044;
tap[3] = -16'd4947;
tap[4] = 16'd15736;
tap[5] = 16'd24625;
tap[6] = -16'd5734;
tap[7] = 16'd2234;
tap[8] = -16'd783;
tap[9] = 16'd164;
end
else if(f >16'd19988 && f<16'd20316) begin
//f = 0.62;
tap[0] = 16'd154;
tap[1] = -16'd726;
tap[2] = 16'd2015;
tap[3] = -16'd4855;
tap[4] = 16'd15387;
tap[5] = 16'd24988;
tap[6] = -16'd5705;
tap[7] = 16'd2213;
tap[8] = -16'd776;
tap[9] = 16'd164;
end
else if(f >16'd20316 && f<16'd20644) begin
//f = 0.63;
tap[0] = 16'd150;
tap[1] = -16'd714;
tap[2] = 16'd1983;
tap[3] = -16'd4763;
tap[4] = 16'd14894;
tap[5] = 16'd25308;
tap[6] = -16'd5677;
tap[7] = 16'd2196;
tap[8] = -16'd769;
tap[9] = 16'd160;
end
else if(f >16'd20644 && f <16'd20972) begin
//f = 0.64;
tap[0] = 16'd150;
tap[1] = -16'd703;
tap[2] = 16'd1944;
tap[3] = -16'd4673;
tap[4] = 16'd14458;
tap[5] = 16'd25619;
tap[6] = -16'd5633;
tap[7] = 16'd2170;
tap[8] = -16'd759;
tap[9] = 16'd157;
end
else if(f >16'd20972 && f<16'd21299) begin
//f = 0.65;:
tap[0] = 16'd147;
tap[1] = -16'd690;
tap[2] = 16'd1905;
tap[3] = -16'd4571;
tap[4] = 16'd14011;
tap[5] = 16'd25914;
tap[6] = -16'd5582;
tap[7] = 16'd2143;
tap[8] = -16'd754;
tap[9] = 16'd157;
end
else if(f >16'd21299 && f<16'd21627) begin
//f = 0.66;
tap[0] = 16'd144;
tap[1] = -16'd678;
tap[2] = 16'd1864;
tap[3] = -16'd4475;
tap[4] = 16'd13585;
tap[5] = 16'd26338;
tap[6] = -16'd5540;
tap[7] = 16'd2129;
tap[8] = -16'd743;
tap[9] = 16'd154;
end
else if(f >16'd21627 && f<16'd21955) begin
//f = 0.67;
tap[0] = 16'd141;
tap[1] = -16'd665;
tap[2] = 16'd1830;
tap[3] = -16'd4376;
tap[4] = 16'd13153;
tap[5] = 16'd26612;
tap[6] = -16'd5487;
tap[7] = 16'd2099;
tap[8] = -16'd730;
tap[9] = 16'd150;
end
else if(f >16'd21955 && f<16'd22282) begin
//f = 0.68;
tap[0] = 16'd137;
tap[1] = -16'd648;
tap[2] = 16'd1783;
tap[3] = -16'd4261;
tap[4] = 16'd12673;
tap[5] = 16'd26956;
tap[6] = -16'd5425;
tap[7] = 16'd2075;
tap[8] = -16'd720;
tap[9] = 16'd150;
end
else if(f >16'd22282 && f<16'd22610) begin
//f = 0.69;
tap[0] = 16'd134;
tap[1] = -16'd635;
tap[2] = 16'd1748;
tap[3] = -16'd4147;
tap[4] = 16'd12282;
tap[5] = 16'd27260;
tap[6] = -16'd5365;
tap[7] = 16'd2037;
tap[8] = -16'd707;
tap[9] = 16'd147;
end
else if(f >16'd22610 && f<16'd22938) begin
//f = 0.70;
tap[0] = 16'd131;
tap[1] = -16'd619;
tap[2] = 16'd1704;
tap[3] = -16'd4031;
tap[4] = 16'd11821;
tap[5] = 16'd27513;
tap[6] = -16'd5271;
tap[7] = 16'd2000;
tap[8] = -16'd693;
tap[9] = 16'd144;
end
else if(f >16'd22938 && f<16'd23265) begin
//f = 0.71;
tap[0] = 16'd127;
tap[1] = -16'd602;
tap[2] = 16'd1662;
tap[3] = -16'd3929;
tap[4] = 16'd11359;
tap[5] = 16'd27849;
tap[6] = -16'd5209;
tap[7] = 16'd1962;
tap[8] = -16'd681;
tap[9] = 16'd141;
end
else if(f >16'd23265 && f<16'd23593) begin
//f = 0.72;
tap[0] = 16'd125;
tap[1] = -16'd586;
tap[2] = 16'd1606;
tap[3] = -16'd3802;
tap[4] = 16'd10991;
tap[5] = 16'd28173;
tap[6] = -16'd5104;
tap[7] = 16'd1922;
tap[8] = -16'd664;
tap[9] = 16'd137;
end
else if(f >16'd23593 && f<16'd23921) begin
//f = 0.73;
tap[0] = 16'd121;
tap[1] = -16'd570;
tap[2] = 16'd1561;
tap[3] = -16'd3686;
tap[4] = 16'd10525;
tap[5] = 16'd28428;
tap[6] = -16'd5023;
tap[7] = 16'd1886;
tap[8] = -16'd652;
tap[9] = 16'd134;
end
else if(f >16'd23921 && f<16'd24248) begin
//f = 0.74;
tap[0] = 16'd118;
tap[1] = -16'd553;
tap[2] = 16'd1515;
tap[3] = -16'd3564;
tap[4] = 16'd10101;
tap[5] = 16'd28795;
tap[6] = -16'd4913;
tap[7] = 16'd1830;
tap[8] = -16'd635;
tap[9] = 16'd131;
end
else if(f >16'd24248 && f<16'd24576) begin
//f = 0.75;
tap[0] = 16'd115;
tap[1] = -16'd533;
tap[2] = 16'd1463;
tap[3] = -16'd3432;
tap[4] = 16'd9675;
tap[5] = 16'd28944;
tap[6] = -16'd4801;
tap[7] = 16'd1793;
tap[8] = -16'd619;
tap[9] = 16'd128;
end
else if(f >16'd24576 && f<16'd24904) begin
//f = 0.76;
tap[0] = 16'd111;
tap[1] = -16'd517;
tap[2] = 16'd1410;
tap[3] = -16'd3309;
tap[4] = 16'd9230;
tap[5] = 16'd29299;
tap[6] = -16'd4695;
tap[7] = 16'd1740;
tap[8] = -16'd599;
tap[9] = 16'd124;
end
else if(f >16'd24904 && f<16'd25231) begin
//f = 0.77;
tap[0] = 16'd108;
tap[1] = -16'd498;
tap[2] = 16'd1362;
tap[3] = -16'd3175;
tap[4] = 16'd8804;
tap[5] = 16'd29530;
tap[6] = -16'd4571;
tap[7] = 16'd1695;
tap[8] = -16'd582;
tap[9] = 16'd121;
end
else if(f >16'd25231 && f<16'd25559) begin
//f = 0.78;
tap[0] = 16'd101;
tap[1] = -16'd478;
tap[2] = 16'd1310;
tap[3] = -16'd3042;
tap[4] = 16'd8382;
tap[5] = 16'd29799;
tap[6] = -16'd4457;
tap[7] = 16'd1638;
tap[8] = -16'd563;
tap[9] = 16'd115;
end 
else if(f >16'd25559 && f<16'd25887) begin
//f = 0.79;
tap[0] = 16'd98;
tap[1] = -16'd458;
tap[2] = 16'd1253;
tap[3] = -16'd2913;
tap[4] = 16'd7961;
tap[5] = 16'd29995;
tap[6] = -16'd4314;
tap[7] = 16'd1583;
tap[8] = -16'd543;
tap[9] = 16'd111;
end
else if(f >16'd25887 && f<16'd26214) begin
//f = 0.80;
tap[0] = 16'd95;
tap[1] = -16'd438;
tap[2] = 16'd1197;
tap[3] = -16'd2785;
tap[4] = 16'd7547;
tap[5] = 16'd30171;
tap[6] = -16'd4170;
tap[7] = 16'd1522;
tap[8] = -16'd524;
tap[9] = 16'd108;
end
else if(f >16'd26214 && f<16'd26542) begin
//f = 0.81;
tap[0] = 16'd88;
tap[1] = -16'd419;
tap[2] = 16'd1143;
tap[3] = -16'd2647;
tap[4] = 16'd7135;
tap[5] = 16'd30393;
tap[6] = -16'd4027;
tap[7] = 16'd1464;
tap[8] = -16'd501;
tap[9] = 16'd105;
end
else if(f >16'd26542 && f<16'd26870) begin
//f = 0.82;
tap[0] = 16'd85;
tap[1] = -16'd398;
tap[2] = 16'd1086;
tap[3] = -16'd2501;
tap[4] = 16'd6725;
tap[5] = 16'd30545;
tap[6] = -16'd3873;
tap[7] = 16'd1403;
tap[8] = -16'd481;
tap[9] = 16'd98;
end
else if(f >16'd26870 && f<16'd27197) begin
//f = 0.83;
tap[0] = 16'd82;
tap[1] = -16'd379;
tap[2] = 16'd1027;
tap[3] = -16'd2372;
tap[4] = 16'd6304;
tap[5] = 16'd30879;
tap[6] = -16'd3710;
tap[7] = 16'd1341;
tap[8] = -16'd458;
tap[9] = 16'd95;
end 
else if(f >16'd27197 && f<16'd27525) begin
//f = 0.84;
tap[0] = 16'd75;
tap[1] = -16'd357;
tap[2] = 16'd974;
tap[3] = -16'd2234;
tap[4] = 16'd5890;
tap[5] = 16'd31015;
tap[6] = -16'd3559;
tap[7] = 16'd1275;
tap[8] = -16'd436;
tap[9] = 16'd88;
end
else if(f >16'd27525 && f<16'd27853) begin
//f = 0.85;
tap[0] = 16'd72;
tap[1] = -16'd337;
tap[2] = 16'd914;
tap[3] = -16'd2097;
tap[4] = 16'd5505;
tap[5] = 16'd31141;
tap[6] = -16'd3370;
tap[7] = 16'd1207;
tap[8] = -16'd412;
tap[9] = 16'd85;
end
else if(f >16'd27853 && f<16'd28180) begin
//f = 0.86;
tap[0] = 16'd69;
tap[1] = -16'd314;
tap[2] = 16'd854;
tap[3] = -16'd1963;
tap[4] = 16'd5092;
tap[5] = 16'd31348;
tap[6] = -16'd3190;
tap[7] = 16'd1135;
tap[8] = -16'd386;
tap[9] = 16'd79;
end
else if(f >16'd28180 &&f<16'd28508) begin
//f = 0.87;
tap[0] = 16'd62;
tap[1] = -16'd294;
tap[2] = 16'd793;
tap[3] = -16'd1811;
tap[4] = 16'd4703;
tap[5] = 16'd31577;
tap[6] = -16'd3000;
tap[7] = 16'd1073;
tap[8] = -16'd363;
tap[9] = 16'd75;
end
else if(f >16'd28508 && f<16'd28836) begin
//f = 0.88;
tap[0] = 16'd59;
tap[1] = -16'd272;
tap[2] = 16'd732;
tap[3] = -16'd1672;
tap[4] = 16'd4313;
tap[5] = 16'd31616;
tap[6] = -16'd2816;
tap[7] = 16'd997;
tap[8] = -16'd337;
tap[9] = 16'd69;
end
else if(f >16'd28836 && f<16'd29164) begin
//f = 0.89;
tap[0] = 16'd52;
tap[1] = -16'd249;
tap[2] = 16'd675;
tap[3] = -16'd1537;
tap[4] = 16'd3934;
tap[5] = 16'd31834;
tap[6] = -16'd2621;
tap[7] = 16'd923;
tap[8] = -16'd311;
tap[9] = 16'd62;
end
else if(f >16'd29164 && f<16'd29491) begin
//f = 0.90;
tap[0] = 16'd49;
tap[1] = -16'd226;
tap[2] = 16'd613;
tap[3] = -16'd1395;
tap[4] = 16'd3552;
tap[5] = 16'd31996;
tap[6] = -16'd2404;
tap[7] = 16'd844;
tap[8] = -16'd285;
tap[9] = 16'd59;
end
else if(f >16'd29491 && f<16'd29819) begin
//f = 0.91;
tap[0] = 16'd43;
tap[1] = -16'd203;
tap[2] = 16'd549;
tap[3] = -16'd1255;
tap[4] = 16'd3171;
tap[5] = 16'd32011;
tap[6] = -16'd2193;
tap[7] = 16'd768;
tap[8] = -16'd259;
tap[9] = 16'd52;
end
else if(f >16'd29819 &&f<16'd30147) begin
//f = 0.92;
tap[0] = 16'd39;
tap[1] = -16'd183;
tap[2] = 16'd491;
tap[3] = -16'd1116;
tap[4] = 16'd2792;
tap[5] = 16'd32183;
tap[6] = -16'd1974;
tap[7] = 16'd688;
tap[8] = -16'd232;
tap[9] = 16'd46;
end
else if(f >16'd30147 && f<16'd30474) begin//
//f = 0.93;
tap[0] = 16'd33;
tap[1] = -16'd160;
tap[2] = 16'd429;
tap[3] = -16'd974;
tap[4] = 16'd2427;
tap[5] = 16'd32385;
tap[6] = -16'd1753;
tap[7] = 16'd605;
tap[8] = -16'd203;
tap[9] = 16'd43;
end
else if(f >16'd30474 && f<16'd30802) begin
//f = 0.94;
tap[0] = 16'd30;
tap[1] = -16'd137;
tap[2] = 16'd367;
tap[3] = -16'd832;
tap[4] = 16'd2067;
tap[5] = 16'd32431;
tap[6] = -16'd1522;
tap[7] = 16'd524;
tap[8] = -16'd177;
tap[9] = 16'd36;
end
else if(f >16'd30802 && f<16'd31130) begin
//f = 0.95;
tap[0] = 16'd23;
tap[1] = -16'd115;
tap[2] = 16'd304;
tap[3] = -16'd690;
tap[4] = 16'd1705;
tap[5] = 16'd32411;
tap[6] = -16'd1282;
tap[7] = 16'd438;
tap[8] = -16'd147;
tap[9] = 16'd30;
end
else if(f >16'd31130 && f<16'd31457) begin
//f = 0.96;
tap[0] = 16'd20;
tap[1] = -16'd92;
tap[2] = 16'd246;
tap[3] = -16'd549;
tap[4] = 16'd1352;
tap[5] = 16'd32555;
tap[6] = -16'd1037;
tap[7] = 16'd354;
tap[8] = -16'd118;
tap[9] = 16'd23;
end
else if(f >16'd31457 && f<16'd31785) begin
//f = 0.97;
tap[0] = 16'd13;
tap[1] = -16'd69;
tap[2] = 16'd183;
tap[3] = -16'd412;
tap[4] = 16'd1006;
tap[5] = 16'd32668;
tap[6] = -16'd787;
tap[7] = 16'd268;
tap[8] = -16'd88;
tap[9] = 16'd20;
end
else if(f >16'd31785 && f<16'd32113) begin
//f = 0.98;
tap[0] = 16'd10;
tap[1] = -16'd46;
tap[2] = 16'd121;
tap[3] = -16'd274;
tap[4] = 16'd669;
tap[5] = 16'd32757;
tap[6] = -16'd530;
tap[7] = 16'd180;
tap[8] = -16'd59;
tap[9] = 16'd13;
end
else if(f >16'd32113 &&f <16'd32440) begin
//f = 0.99;
tap[0] = 16'd3;
tap[1] = -16'd23;
tap[2] = 16'd62;
tap[3] = -16'd137;
tap[4] = 16'd330;
tap[5] = 16'd32758;
tap[6] = -16'd268;
tap[7] = 16'd92;
tap[8] = -16'd30;
tap[9] = 16'd7;
end
end
end

localparam IDLE =0; //checking logic for interpolator
localparam LOAD_BUF =1;  // loading the data in a buffer
localparam MULTIPLY =2;  // multiplying to taps
localparam ACCUMULATE =3; // adding all the accumulator to data_out
localparam HOLD =4; // state at which output is getting holded untill next output change


  // Latch interpolator_en for 3 clock cycles
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pulse_counter <= 0;
            interpolator_en_latched <= 0;
        end else begin
            if (gardner_en)
                pulse_counter <= 2'd3;
            else if (pulse_counter > 0)
                pulse_counter <= pulse_counter - 1;

            interpolator_en_latched <= (pulse_counter > 0);
        end
    end

    always@(posedge clk or negedge rst_n)begin
        if(count == 9)begin
            gardner_en <=1;
            count <=0;
        end
        else begin
            gardner_en <=0;
            count <= count +1;
        end
    end



			
    // FSM logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers
            buffer[0] <= 0; buffer[1] <= 0; buffer[2] <= 0; buffer[3] <= 0; buffer[4] <= 0;
            buffer[5] <= 0; buffer[6] <= 0; buffer[7] <= 0; buffer[8] <= 0; buffer[9] <= 0;

            accumulator[0] <= 0; accumulator[1] <= 0; accumulator[2] <= 0; accumulator[3] <= 0; accumulator[4] <= 0;
            accumulator[5] <= 0; accumulator[6] <= 0; accumulator[7] <= 0; accumulator[8] <= 0; accumulator[9] <= 0;

            temp_data_out <= 0;
            data_out <= 0;
            data_out_en <= 0;
            count <=0;
            gardner_en <=1;
            state <= IDLE;

        end else begin
            case (state)
                IDLE: begin
                    data_out_en <= 0;
                    if (interpolator_en_latched)
                        state <= LOAD_BUF;
                end

                LOAD_BUF: begin
                    // Shift buffer
                    buffer[9] <= buffer[8];
                    buffer[8] <= buffer[7];
                    buffer[7] <= buffer[6];
                    buffer[6] <= buffer[5];
                    buffer[5] <= buffer[4];
                    buffer[4] <= buffer[3];
                    buffer[3] <= buffer[2];
                    buffer[2] <= buffer[1];
                    buffer[1] <= buffer[0];
                    buffer[0] <= data_in;

                    state <= MULTIPLY;
                end

                MULTIPLY: begin
                    accumulator[0] <= tap[0] * buffer[0];
                    accumulator[1] <= tap[1] * buffer[1];
                    accumulator[2] <= tap[2] * buffer[2];
                    accumulator[3] <= tap[3] * buffer[3];
                    accumulator[4] <= tap[4] * buffer[4];
                    accumulator[5] <= tap[5] * buffer[5];
                    accumulator[6] <= tap[6] * buffer[6];
                    accumulator[7] <= tap[7] * buffer[7];
                    accumulator[8] <= tap[8] * buffer[8];
                    accumulator[9] <= tap[9] * buffer[9];

                    state <= ACCUMULATE;
                end

                ACCUMULATE: begin
                    temp_data_out <= accumulator[0] + accumulator[1] + accumulator[2] + accumulator[3] +
                                     accumulator[4] + accumulator[5] + accumulator[6] + accumulator[7] +
                                     accumulator[8] + accumulator[9];
                    state <= HOLD;

					data_out <= temp_data_out[31:16];
					data_out_en <=1;
                end

                HOLD: begin
                    data_out <= temp_data_out[31:16]; // Truncate to 8.8 format
                    data_out_en <= 1;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
            
        
		

			
			

