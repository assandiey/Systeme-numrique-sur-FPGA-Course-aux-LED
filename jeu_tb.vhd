------------------------------------------------------------------------------------------------
-- UNIVERSITE DU QUEBEC A MONTREAL
-- MIC6130 : CIRCUITS INTEGRES PROGRAMMABLES
-- PROJET FIN DE SESSION
-- ASSANE DIEYE  
-- AUTOMNE 2024
-- VERSION DECEMBRE 2024 
-- JEU " COURSE AUX LED "
-- MODULE "jeu_tb"
------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity jeu_tb is
end jeu_tb;

architecture Behavioral of jeu_tb is

 COMPONENT debound
    PORT(
         clk : in  std_logic;
         reset : in  std_logic;
         m_tick : in  std_logic;
         Sw : in  std_logic;
         db : out  std_logic
        );
    end component;
    
    component top
        port (
            RSTN : in  std_logic;
            CLK  : in  std_logic;
            LED  : out std_logic_vector(7 downto 0);
            SW   : in  std_logic_vector(7 downto 0);
            jb   : out std_logic_vector(8 downto 1);
            jc   : out std_logic_vector(8 downto 1);
            BTN  : in  std_logic_vector(5 downto 0)
        );
    end component;
   
------------------------------------------------------------------------------------------------------------------------
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal m_tick : std_logic := '0';
   signal Ss : std_logic := '0';
   signal db : std_logic := '0';
   constant period_h : time := 10 ns;

    signal RSTN      : std_logic := '0';
    signal LED       : std_logic_vector(7 downto 0);
    signal SW        : std_logic_vector(7 downto 0) := (others => '0');
    signal jb        : std_logic_vector(8 downto 1);
    signal jc        : std_logic_vector(8 downto 1);
    signal BTN       : std_logic_vector(5 downto 0) := (others => '0');
    signal db_Btn    : std_logic_vector(5 downto 0) := (others => '0');
    signal m_tick1   : std_logic := '0';
------------------------------------------------------------------------------------------------------------------------
begin 

    deb_btn : for i in 0 to 5 generate
        debound_btn: debound
        port map (
            CLK    => CLK,
            reset  => RSTN,
            m_tick => m_tick1,
            SW     => BTN(i),
            db     => db_Btn(i)
        );
    end generate;
        
          
    DUT: top
        port map (
            RSTN => RSTN,
            CLK  => CLK,
            LED  => LED,
            SW   => SW,
            jb   => jb,
            jc   => jc,
            BTN  => db_Btn
        );
        
------------------------------------------------------------------------------------------------------------------------
        
   process_clk :process
   begin
		clk <= '0';
		wait for period_h/2;
		clk <= '1';
		wait for period_h/2;
   end process;
 
  process_tick :process
   begin
	  m_tick <= '1';
     wait for 5 ns;
     m_tick <= '0';
     wait for 15 ns;
   end process;
 

   simulation: process
   begin	

   -- appui sur BTN(2) pour incrémenter les LEDs
    BTN(2) <= '1'; 
    wait for 200 ns; 
  BTN(2) <= '0'; 
    wait for 200 ns;
    
    -- appui sur BTN(3) pour décrémenter les LEDs
BTN(3) <= '1'; 
    wait for 200 ns; 
    BTN(3) <= '0'; 
    wait for 200 ns;			         



    wait;
	end process;
	
	
end Behavioral;