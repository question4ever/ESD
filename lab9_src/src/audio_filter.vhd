--audio_filter.vhd
--lab 8 ESD1 
--Author: Scott Avery
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  

entity audio_filter is
port (
	clk, reset_n : in std_logic;
    write		 : in std_logic;
    address      : in std_logic;
    writedata    : in std_logic_vector(15 downto 0);
    readdata     : out std_logic_vector(15 downto 0)
    );
end audio_filter;

architecture a of audio_filter is
    
    type ARRAY_TYPE is array (0 to 16) of signed(15 downto 0);
    type MULT_RESULT is array (0 to 16) of signed(31 downto 0);
    
    signal lp_coef : ARRAY_TYPE := (0 => x"0051", 1 => x"00BA", 2 => x"01E2", 3 => x"0407", 4 => x"071A", 5 => x"0AAC", 6 => x"0E10", 7 => x"107F", 8 => x"1161", 
        9 => x"107F", 10 => x"0E10", 11 => x"0AAC", 12 => x"071A", 13 => x"0407", 14 => x"01E2", 15 => x"00BA", 16 => x"0051");
	
	signal hp_coef : ARRAY_TYPE := (0 => x"003E", 1 => x"FF9A", 2 => x"FE9E", 3 => x"0000", 4 => x"0536", 5 => x"05B2", 6 => x"F5AC", 7 => x"DAB7", 8 => x"4C92", 
        9 => x"DAB7", 10 => x"F5AC", 11 => x"05B2", 12 => x"0536", 13 => x"0000", 14 => x"FE9E", 15 => x"FF9A", 16 => x"003E");
        
    signal coef : ARRAY_TYPE;
        
    signal mult_r : MULT_RESULT := (others => x"00000000");
    
    signal sum : MULT_RESULT := (others => x"00000000");
	signal d_in : ARRAY_TYPE := (others => x"0000");
    signal data_in : signed(15 downto 0) :=  x"0000";
    signal data_out : signed(15 downto 0) := x"0000";
    
    signal switch : std_logic_vector(15 downto 0) := x"0000";
	signal filter_en : std_logic := '1';
        
    component multiplier is
    PORT  (
		dataa  : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		datab  : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		result : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
    end component;

begin

    --Choose coefficients 
    process(switch)
    begin 
        for i in 0 to 16 loop
            if(switch(0) = '0') then
                coef(i) <= lp_coef(i);
            else
                coef(i) <= hp_coef(i);
            end if;
        end loop;
    end process;

    --r/w to registers 
    process(clk, reset_n, address, writedata, write)
    begin
        if(reset_n = '0') then
            data_in <= x"0000";
            switch <= x"0000";
        elsif(clk'event and clk = '1') then
            if(write = '1') then
                if(address = '0') then
                    data_in <= signed(writedata); --input data
                else
                    switch <= writedata; -- high pass or low pass
                end if;
            else 
                -- if(address = '0') then
                    -- readdata <= std_logic_vector(data_out); --input data
                -- else
                    -- readdata <= switch; -- high pass or low pass
                -- end if;
            end if;
        end if;
    end process;

    --Multiply coefficients by input data
    GEN_MULT: for i in 0 to 16 generate
        begin
        MULTX: multiplier port map
        (
            dataa  => std_logic_vector(d_in(i)),
            datab  => std_logic_vector(coef(i)),
            signed(result) => mult_r(i)
        );
        end generate;

    process(mult_r, sum)
    begin
        for i in 0 to 16 loop
            if(i = 0) then
                sum(0) <= mult_r(0) + mult_r(1); 
            elsif(i /= 0) then
                sum(i) <= sum(i - 1) + mult_r(i);
            end if; 
        end loop; 
    end process;
	
	
	DFF: process(clk, reset_n, data_in)
	begin
		if(reset_n = '0') then
			d_in <= (others => x"00000");
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
	
	data_out <= sum(16)(30 downto 15);
	readdata <= std_logic_vector(data_out); --input data
        
end a;