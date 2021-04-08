library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity Lab4 is
	port(Clk 		   : in std_logic; -- zegar zewnêtrzny 1 Hz
		  button_start : in std_logic; -- przycisk start/stop
		  button_save  : in std_logic; -- przycisk zapisywania
		  time_h 	 	: inout std_logic_vector (4 downto 0) := "00000"; -- aktualna godzina
		  time_m 	 	: inout std_logic_vector (5 downto 0) := "000000"; -- aktualna minuta
		  time_s		 	: inout std_logic_vector (5 downto 0) := "000000"; -- aktualna sekunda
		  counting   	: inout std_logic := '0'; -- czy zegarek pracuje? (zezwolenia na pracê zegarka)
		  -- zapamiêtane stany stopera:
		  mem1_h, mem2_h, mem3_h, mem4_h, mem5_h : inout std_logic_vector (4 downto 0) := "00000";
		  mem1_m, mem2_m, mem3_m, mem4_m, mem5_m : inout std_logic_vector (5 downto 0) := "000000";
		  mem1_s, mem2_s, mem3_s, mem4_s, mem5_s : inout std_logic_vector (5 downto 0) := "000000");

end Lab4;

architecture Behavioral of Lab4 is

-- Zegarek ---------------------------------------------------------------------------
procedure zegarek
	(signal zeg   : in std_logic; -- zegar zewnêtrzny 1 Hz
	 signal licz  : in std_logic; -- wejœcie zezwalaj¹ce na pracê zegarka
	 signal zeg_g : inout std_logic_vector (4 downto 0); -- liczba godzin
	 signal zeg_m : inout std_logic_vector (5 downto 0); -- liczba minut
	 signal zeg_s : inout std_logic_vector (5 downto 0)) is -- liczba sekund
begin
	if (licz = '1') then
		 if (zeg'event and zeg = '1') then
			if (zeg_s < 59) then
				zeg_s <= zeg_s + 1;
			else
				zeg_s <= "000000";
				if (zeg_m < 59) then
					zeg_m <= zeg_m + 1;
				else
					zeg_m <= "000000";
					if (zeg_g < 23) then
						zeg_g <= zeg_g + 1;
					else
						zeg_g <= "00000";
					end if;
				end if;
			end if;
		end if;
	end if;
end zegarek;
--------------------------------------------------------------------------------------

-- Pamiêæ ----------------------------------------------------------------------------
procedure pamiec
	(signal in_h : inout std_logic_vector (4 downto 0); -- zapisywana godzina
	 signal in_m : inout std_logic_vector (5 downto 0); -- zapisywana minuta
	 signal in_s : inout std_logic_vector (5 downto 0); -- zapisywana sekunda
	 -- zapamiêtane stany stopera:
	 signal pam1_h, pam2_h, pam3_h, pam4_h, pam5_h : inout std_logic_vector (4 downto 0);
	 signal pam1_m, pam2_m, pam3_m, pam4_m, pam5_m : inout std_logic_vector (5 downto 0);
    signal pam1_s, pam2_s, pam3_s, pam4_s, pam5_s : inout std_logic_vector (5 downto 0)) is				
begin
	-- przesuniêcie 4 najnowszych rekordów i "usuniêcie" najstarszego
	pam5_h <= pam4_h; pam5_m <= pam4_m; pam5_s <= pam4_s;
	pam4_h <= pam3_h; pam4_m <= pam3_m; pam4_s <= pam3_s;
	pam3_h <= pam2_h; pam3_m <= pam2_m; pam3_s <= pam2_s;
	pam2_h <= pam1_h; pam2_m <= pam1_m; pam2_s <= pam1_s;
	-- wpisanie nowego rekordu
	pam1_h <= in_h; pam1_m <= in_m; pam1_s <= in_s;
end pamiec;
--------------------------------------------------------------------------------------

begin

	-- reakcja uk³adu na przycisk start/stop
	process (button_start)
	begin
		if (button_start'event and button_start = '1') then
			counting <= not counting;
			if (counting = '0') then -- jeœli stoper startuje, to trzeba go wyzerowaæ
				time_h <= "00000";
				time_m <= "000000";
				time_s <= "000000";
			end if;
		end if;
	end process;
		
	-- praca stopera
	process (Clk, counting)
	begin
		zegarek(Clk, counting, time_h, time_m, time_s);
	end process;
	
	-- reakcja uk³adu na przycisk zapisu
	process (button_save)
	begin
		if (button_save'event and button_save = '1') then
			pamiec(time_h, time_m, time_s, mem1_h, mem2_h, mem3_h, mem4_h, mem5_h, mem1_m, 
					 mem2_m, mem3_m, mem4_m, mem5_m, mem1_s, mem2_s, mem3_s, mem4_s, mem5_s);
		end if;
	end process;
	
end Behavioral;

