library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use std.textio.all;

package std_converter is
  function to_hstring (SLV : std_logic_vector) return string;
end package std_converter;

package body std_converter is

----------------------------------------
function to_hstring (SLV : std_logic_vector) return string is
    variable L : LINE;
    begin
        hwrite(L,SLV);
    return L.all;
end function to_hstring;
----------------------------------------

end package body std_converter;
