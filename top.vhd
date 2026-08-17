------------------------------------------------------------------------------------------------
-- UNIVERSITE DU QUEBEC A MONTREAL
-- MIC6130 : CIRCUITS INTEGRES PROGRAMMABLES
-- PROJET FIN DE SESSION
-- ASSANE DIEYE  
-- AUTOMNE 2024
-- VERSION DECEMBRE 2024 
-- JEU " COURSE AUX LED "
-- MODULE "Top"
------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.numeric_std.all;

entity top is
port(
    RSTN      : in  STD_LOGIC;
    CLK       : in  STD_LOGIC;
    LED       : out STD_LOGIC_VECTOR(7 downto 0);
    SW        : in  STD_LOGIC_VECTOR(7 downto 0);
    jb        : out STD_LOGIC_VECTOR(8 downto 1);
    jc        : out STD_LOGIC_VECTOR(8 downto 1);
    BTN       : in  STD_LOGIC_VECTOR(5 downto 0)
    
);
end top;

architecture Behavioral of top is
------------------------------------------------------------------------------------------------
                --  DECLARATIONS ET INITIALISATIONS DES SIGNAUX --
------------------------------------------------------------------------------------------------

    signal led_actuel   : integer range 0 to 10 := 3;  
    signal btn_presse   : std_logic := '0';      
    signal gagnant      : integer range 0 to 2 := 0;    
    signal db_Btn       : std_logic_vector(5 downto 0):= "000000";
    signal m_tick1      : std_logic;
    signal db           : std_logic;
    signal reset        : std_logic;
    
    signal affichage_gagant : std_logic_vector(6 downto 0):= "0000000";
    signal digit_select_sig : std_logic;
    signal segments_sig     : std_logic_vector(6 downto 0);

 ------------------------------------------------------------------------------------------------
                                    --  COMPONENT --
------------------------------------------------------------------------------------------------   
    component debound
        PORT (
            CLK       : in std_logic; 
            reset     : in std_logic;
            m_tick    : in std_logic;
            SW        : in std_logic;
            db        : out std_logic
        );
    end component;

    component m_tick
        PORT (
            CLK       : in std_logic;
            m_tick    : out std_logic
        );
    end component;

    component pmod_seven_segments
        GENERIC (
            clk_freq : INTEGER := 100  
        );
        PORT (
            clk         : in std_logic;                
            reset_n     : in std_logic;                
            number      : in std_logic_vector(6 downto 0); -- NOMBRE A AFFICHE
            digit_select: buffer std_logic;            
            segments    : out std_logic_vector(6 downto 0)  
        );
    end component;

begin
------------------------------------------------------------------------------------------------
                                --  INSTANTIATION --
------------------------------------------------------------------------------------------------
    
    deb_btn : for i in 0 to 5 generate
        debound_btn : debound
        port map(
            CLK      => CLK,
            reset    => reset,
            SW       => BTN(i),
            m_tick   => m_tick1,
            db       => db_Btn(i)
        );
    end generate;

    
    m_tick_1 : m_tick
        port map(
            CLK     => CLK,
            m_tick  => m_tick1
        );

  
    Inst_pmod_seven_segments_1 : pmod_seven_segments
        GENERIC MAP (
            clk_freq => 100  
        )
        PORT MAP (
            clk            => CLK,               
            reset_n        => RSTN,              
            number         => affichage_gagant, 
            digit_select   => digit_select_sig,
            segments       => segments_sig     
        );
        

------------------------------------------------------------------------------------------------
                                    --  PROCESS --
------------------------------------------------------------------------------------------------
    -- PROCESS LED avec BTN(0) pour reinitialiser
    process(CLK)
    begin
        if rising_edge(CLK) then
            -- reinitialisation avec BTN(0)
            if db_Btn(0) = '1' then
                led_actuel <= 3;
                gagnant <= 0;
                btn_presse <= '0';
            else
                -- gestion des bouttons
                if led_actuel /= 0 and led_actuel /= 7 then
				
                    if db_Btn(2) = '1' and btn_presse = '0' then  
                   btn_presse <= '1'; 
                        led_actuel <= led_actuel + 1;
                    elsif db_Btn(3) = '1' and btn_presse = '0' then  
                        btn_presse <= '1'; 
                         led_actuel <= led_actuel - 1;
                    elsif db_Btn(2) = '0' and db_Btn(3) = '0' then
                         btn_presse <= '0';  
                    end if;
                end if;
                
                -- gestion du gagnant 
                if led_actuel = 0 then
                    gagnant <= 1;
                elsif led_actuel = 7 then
                    gagnant <= 2;
                end if;
            end if;
        end if;
    end process;

------------------------------------------------------------------------------------------------
                                    --  PROCESS DES LED --
------------------------------------------------------------------------------------------------
    process(led_actuel)
    begin
        case led_actuel is
            when 0 => LED <= "00000001";  
            when 1 => LED <= "00000010";  
            when 2 => LED <= "00000100";  
            when 3 => LED <= "00001000";  
            when 4 => LED <= "00010000";  
            when 5 => LED <= "00100000";  
            when 6 => LED <= "01000000";  
            when 7 => LED <= "10000000";  
            when others => LED <= "00000001"; 
        end case;
    end process;


------------------------------------------------------------------------------------------------
                                    --  AFFICHAGE SUR 7 SEGMENTS --
------------------------------------------------------------------------------------------------

    affichage_gagant <= std_logic_vector(TO_UNSIGNED(gagnant, affichage_gagant'length));

    jb(1)   <= segments_sig(5);
    jb(2)   <= segments_sig(6);
    jb(3)   <= segments_sig(3);
    jb(4)   <= segments_sig(4);
    
    jc(1)   <= segments_sig(1);
    jc(2)   <= segments_sig(2);
    jc(3)   <= digit_select_sig;
    jc(4)   <= segments_sig(0);
    
 

end Behavioral;
------------------------------------------------------------------------------------------------
                                    --  FIN --
------------------------------------------------------------------------------------------------