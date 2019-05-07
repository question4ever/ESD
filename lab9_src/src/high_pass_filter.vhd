--low_pass_filter.vhd
--lab 8 ESD1 
--Author: Scott Avery
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  

entity high_pass_filter is
port (
	clk, reset_n : in std_logic;
    filter_en : in std_logic;
    data_in : in signed(15 downto 0);
    data_out : out signed(15 downto 0));
end high_pass_filter;

architecture a of high_pass_filter is
    
    type ARRAY_TYPE is array (0 to 16) of signed(15 downto 0);
    type MULT_RESULT is array (0 to 16) of signed(31 downto 0);
    
    signal lp_coef : ARRAY_TYPE := (0 => x"003E", 1 => x"FF9A", 2 => x"FE9E", 3 => x"0000", 4 => x"0536", 5 => x"05B2", 6 => x"F5AC", 7 => x"DAB7", 8 => x"4C92", 
        9 => x"DAB7", 10 => x"F5AC", 11 => x"05B2", 12 => x"0536", 13 => x"0000", 14 => x"FE9E", 15 => x"FF9A", 16 => x"003E");
    
    signal mult_r : MULT_RESULT := (others => x"00000000");
    
    signal sum : MULT_RESULT := (others => x"00000000");
	signal d_in : ARRAY_TYPE := (others => x"0000");
        
    component multiplier is
    PORT  (
		dataa  : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		datab  : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		result : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
    end component;

begin

    GEN_MULT: for i in 0 to 16 generate
        begin
        MULTX: multiplier port map
        (
            dataa  => std_logic_vector(d_in(i)),
            datab  => std_logic_vector(lp_coef(i)),
            signed(result) => mult_r(i)
        );
        end generate;

    process(mult_r, sum)
    begin
        for i in 0 to 15 loop
            if(i = 0) then
                sum(0) <= mult_r(0) + mult_r(1);
            else
                sum(i) <= sum(i - 1) + mult_r(i + 1);
            end if; 
        end loop; 
    end process;
	
	
	DFF: process(clk, reset_n, data_in)
	begin
		if(reset_n = '0') then
			d_in <= (others => x"0000");
		elsif(clk'event and clk = '1') then
			if(filter_en = '1') then
                d_in(0) <= data_in;
                d_in(1) <= d_in(0);
                d_in(2) <= d_in(1);
                d_in(3) <= d_in(2);
                d_in(4) <= d_in(3);
                d_in(5) <= d_in(4);
                d_in(6) <= d_in(5);
                d_in(7) <= d_in(6);
                d_in(8) <= d_in(7);
                d_in(9) <= d_in(8);
                d_in(10) <= d_in(9);
                d_in(11) <= d_in(10);
                d_in(12) <= d_in(11);
                d_in(13) <= d_in(12);
                d_in(14) <= d_in(13);
                d_in(15) <= d_in(14);
                d_in(16) <= d_in(15);
			end if;
		end if;
	end process DFF;
	
	data_out <= sum(15)(30 downto 15);
        
end a;