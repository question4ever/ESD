--low_pass_filter.vhd
--lab 8 ESD1 
--Author: Scott Avery
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  

entity low_pass_filter is
port (
	clk, reset_n : in std_logic;
    filter_en : in std_logic;
    data_in : in signed(15 downto 0);
    data_out : out signed(15 downto 0));
end low_pass_filter;

architecture a of low_pass_filter is
    
    type ARRAY_TYPE is array (0 to 16) of std_logic_vector(15 downto 0);
    type MULT_RESULT is array (0 to 16) of std_logic_vector(31 downto 0);
    
    signal lp_coef : ARRAY_TYPE := (0 => x"0051", 1 => x"00BA", 2 => x"01E2", 3 => x"0407", 4 => x"071A", 5 => x"0AAC", 6 => x"0E10", 7 => x"107F", 8 => x"1161", 
        9 => x"107F", 10 => x"0E10", 11 => x"0AAC", 12 => x"071A", 13 => x"0407", 14 => x"01E2", 15 => x"00BA", 16 => x"0051");
    
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
            dataa  => d_in(i),
            datab  => lp_coef(i),
            result => mult_r(i)
        );
        end generate;

    process(mult_r, sum)
    begin
        for i in 0 to 16 loop
            if(i = 0) then
                sum(0) <= std_logic_vector(signed(mult_r(0)) + signed(mult_r(1))); 
            elsif(i /= 0) then
                sum(i) <= std_logic_vector(signed(sum(i - 1)) + signed(mult_r(i)));
            end if; 
        end loop; 
    end process;
	
	
	DFF: process(clk, reset_n, data_in)
	begin
		if(reset_n = '0') then
			d_in <= (others => x"00000");
		elsif(clk'event and clk = '1') then
			if(filter_en = '1') then
                d_in(0) <= std_logic_vector(data_in);
                d_in(16 downto 1) <= d_in(15 downto 0);
			end if;
		end if;
	end process DFF;
	
	data_out <= signed(sum(16)(30 downto 15));
        
end a;