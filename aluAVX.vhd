library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity avxALU is
  port (
	A  : in std_logic_vector(31 downto 0);
	B  : in std_logic_vector(31 downto 0);

	vecSize : in std_logic_vector(1 downto 0);
	mode : in std_logic;

	S   : out std_logic_vector(31 downto 0);

	zero : out std_logic
    );
end avxALU;


architecture rtl of avxALU is

  signal w_G : std_logic_vector(31 downto 0); -- Generate
  signal w_P : std_logic_vector(31 downto 0); -- Propagate
  signal w_C : std_logic_vector(32 downto 0);   -- Carry

  signal w_SUM  : std_logic_vector(31 downto 0);

  signal BB : std_logic_vector(31 downto 0);

begin

 	gen_B : for ii in 0 to 31 generate
		b_inst : BB(ii) <= B(ii) when mode = '0' else B(ii) xor '1';
	end generate gen_B;
  	w_C(0) <= mode;

  -- Create the Full Adders
	GEN_FULL_ADDERS : for ii in 0 to 31 generate
		FULL_ADDER_INST : w_SUM(ii) <= A(ii) xor BB(ii) xor w_C(ii);
	end generate GEN_FULL_ADDERS;

  -- Create the Generate (G) Terms:  Gi=Ai*Bi
  -- Create the Propagate Terms: Pi=Ai+Bi
  -- Create the Carry Terms:
	GEN_CLA : for jj in 0 to 31 generate
		w_G(jj)   <= A(jj) and BB(jj);
		w_P(jj)   <= A(jj) or BB(jj);
		--if ((vecSize = "00") and boolean(jj mod 4)) then
		w_C(jj+1) <= mode when ( ( (((jj+1) mod 4) = 0) and (vecSize = "00")) or ( (((jj+1) mod 8) = 0) and (vecSize = "01")) or ( (((jj+1) mod 16) = 0) and (vecSize = "10")))
					else w_G(jj) or (w_P(jj) and w_C(jj));
	end generate GEN_CLA;



  S <= w_SUM;  -- VHDL Concatenation

  zero <= '1' when w_SUM = x"00000000" else '0';

end rtl;