
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity monopulse_gen is
  port (
    clk    : in std_logic;
    btn    : in std_logic_vector(4  downto 0);
    enable : out std_logic_vector(4 downto 0)
  );
end entity monopulse_gen;

architecture behavioral of monopulse_gen is  

signal s_cnt_out    : std_logic_vector(15 downto 0);
signal s_en         : std_logic;
signal s_d_ff1_out  : std_logic_vector(4 downto 0);
signal s_d_ff2_out  : std_logic_vector(4 downto 0);
signal s_d_ff3_out  : std_logic_vector(4 downto 0);

begin
    -- 16-bit counter
    process(clk)
        begin
        if rising_edge(clk) then
            s_cnt_out <= s_cnt_out + 1; 
        end if;
    end process;
    

    -- enable signal
    s_en <= '1' when s_cnt_out = x"000f" else '0';
    
    -- D flip-flop 1
    process(clk)
        begin
        if rising_edge(clk) then
            if s_en = '1' then
                s_d_ff1_out <= btn;
            end if;
        end if;
    end process;
    
    -- D flip-flop 2
    process(clk)
        begin
        if rising_edge(clk) then
            s_d_ff2_out <= s_d_ff1_out;
        end if;
    end process;
    
    -- D flip-flop 3
    process(clk)
        begin
        if rising_edge(clk) then
            s_d_ff3_out <= s_d_ff2_out;
        end if;
    end process;
    
    -- AND gate at the end
    enable <= s_d_ff2_out and not s_d_ff3_out;
    
end architecture behavioral; 
