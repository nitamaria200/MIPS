library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity exec_unit is
  port (
    -- inputs
    ext_imm     : in std_logic_vector(15 downto 0);
    func        : in std_logic_vector(2  downto 0);
    rd1         : in std_logic_vector(15 downto 0);
    rd2         : in std_logic_vector(15 downto 0);        
    pc_plus_one : in std_logic_vector(15 downto 0);
    sa          : in std_logic;
    -- control signals
    alu_op    : in  std_logic_vector(2 downto 0);
    alu_src   : in  std_logic;
    -- outputs
    alu_res : out std_logic_vector(15 downto 0);
    bta     : out std_logic_vector(15 downto 0);
    zero    : out std_logic
  );
end entity;

architecture rtl of exec_unit is

  signal s_alu_control    : std_logic_vector(2  downto 0);
  signal s_alu_res        : std_logic_vector(15 downto 0);
  signal s_second_operand : std_logic_vector(15 downto 0);

begin

  process (alu_op, func)
  begin
    case alu_op is
      when "000" =>
        case func is
            when "000"  => s_alu_control <= "000"; -- ADD
            when "001"  => s_alu_control <= "001"; -- SUB
            when "010"  => s_alu_control <= "010"; -- SLL
            when "011"  => s_alu_control <= "011"; -- SRL
            when "100"  => s_alu_control <= "100"; -- AND
            when "101"  => s_alu_control <= "101"; -- OR
            when "110"  => s_alu_control <= "110"; -- XOR
            when "111"  => s_alu_control <= "111"; -- SLT
            when others => s_alu_control <= "000";
        end case;        
      when "001"  => s_alu_control <= "000"; -- ADDI
      when "010"  => s_alu_control <= "000"; -- LW
      when "011"  => s_alu_control <= "000"; -- SW
      when "100"  => s_alu_control <= "001"; -- BEQ
      when "101"  => s_alu_control <= "101"; -- ORI
      when "110"  => s_alu_control <= "111"; -- SLTI
      when others => s_alu_control <= "000";
    end case;
  end process;

  -- MUX for Second Operand
  s_second_operand <= rd2 when alu_src = '0' else ext_imm;

  -- ALU
  process (s_alu_control, sa, rd1, s_second_operand)
  begin
    case s_alu_control is
      when "000"  => s_alu_res <= rd1 + s_second_operand;
      when "001"  => s_alu_res <= rd1 - s_second_operand;
      when "010"  => s_alu_res <= rd1(14 downto 0)&'0';
      when "011"  => s_alu_res <= '0'&rd1(15 downto 1);
      when "100"  => s_alu_res <= rd1 and s_second_operand;
      when "101"  => s_alu_res <= rd1 or s_second_operand;
      when "110"  => s_alu_res <= rd1 xor s_second_operand;
      when "111"  => 
        if rd1 < s_second_operand then
            s_alu_res <= x"0001";
        else
            s_alu_res <= x"0000";
        end if;
      when others => s_alu_res <= (others => '0');
    end case;    
  end process;
  
  alu_res <= s_alu_res; -- DUE TO ZERO FLAG, output cannot be a variable for condition in 'when' statement

  -- Branch Target Address
  bta <= ext_imm + pc_plus_one;
  
  -- Zero Flag
  zero <= '1' when s_alu_res = x"0000" else '0';

end architecture;