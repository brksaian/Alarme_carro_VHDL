-- A entidade AlarmeCarro possui cinco portas de entrada: remoto, sensores, clock, reset, e uma porta de saída chamada sirene.
-- Na arquitetura Alarme, temos dois processos. 
--		- O primeiro é sensível aos sinais clock e reset e é responsável por atualizar o estado atual (estado_atual) com o próximo estado (estado_proximo). 
--		- O segundo processo é sensível ao estado atual, bem como aos sinais remoto e sensores. 
-- Usando uma estrutura de caso (case), o processo define as transições de estado com base nas condições fornecidas.
-- O alarme possui três estados: desarmado, armado e alarme. 
-- O estado inicial é desarmado e pode mudar para armado ou vice-versa quando o sinal remoto é ativado (remoto = '1'). 
-- Quando está no estado armado, se o sinal sensores for ativado (sensores = '1'), o alarme muda para o estado alarme e ativa a sirene. 
-- Para desarmar o alarme, é necessário outro comando remoto (remoto = '1').

library ieee;
use ieee.std_logic_1164.all;

entity AlarmeCarro is
    port (
        remoto   : in  std_logic; -- Entrada remoto setada como logica, alta ou baixa
        sensor : in  std_logic; -- Entrada do sensor setada como logica, alta ou baixa
        clock    : in  std_logic; -- Entrada do clock setada como logica, alta ou baixa
        reset    : in  std_logic; -- Entrada do reset setada como logica, alta ou baixa
        sirene   : out std_logic -- Saida da sirene setada como logica, alta ou baixa
    );
end entity AlarmeCarro;

architecture Alarme of AlarmeCarro is
    type Estado is (desarmado, armado, alarme); -- Define os possiveis estados do alarme
    signal estado_atual, estado_proximo : Estado; -- Seta os "fios" de conexão com o tipo de 'Estado'
begin
    process (clock, reset) -- Tratamento do clock e reset
    begin
        if reset = '1' then -- Caso o botão de reset seja pressionado
            estado_atual <= desarmado;  --  O estado atual é setado como desarmado
        elsif rising_edge(clock) then -- Caso o estado atual do clock seja alto
            estado_atual <= estado_proximo;  -- Atualiza o estado atual com o próximo estado
        end if;
    end process;

    process (estado_atual, remoto, sensor) -- Tratamento do alarme em si
    begin
        case estado_atual is -- Switch case do estado atual do alarme
            when desarmado => -- Caso esteja desarmado
                if remoto = '1' then -- Se o remoto for clicado
                    estado_proximo <= armado;  -- Muda para o estado armado quando ocorre remoto='1'
                else
                    estado_proximo <= desarmado;  -- Mantém no estado desarmado
                end if;

            when armado => -- Caso esteja armado
                if sensor = '1' then -- Se o sensor identificar algo
                    estado_proximo <= alarme;  -- Muda para o estado alarme quando ocorre sensor='1'
                elsif remoto = '1' then -- Se o remoto for clicado
                    estado_proximo <= desarmado;  -- Muda para o estado desarmado quando ocorre remoto='1'
                else
                    estado_proximo <= armado;  -- Mantém no estado armado
                end if;

            when alarme =>
                if remoto = '1' then -- Se o remoto for clicado
                    estado_proximo <= desarmado;  -- Muda para o estado desarmado quando ocorre remoto='1'
                else
                    estado_proximo <= alarme;  -- Mantém no estado de alarme
                end if;
        end case;
    end process;

    sirene <= '1' when estado_atual = alarme else '0';  -- Ativa a sirene quando no estado alarme
end architecture Alarme;