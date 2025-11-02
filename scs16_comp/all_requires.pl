
BEGIN {

require $base_dir.'scs16_asm_init.pl';
&define_all;	
require $base_dir.'generic_subs.pl';
require $base_dir.'flow_control.pl';
require $base_dir.'statment_sorter.pl';

require $base_dir.'cmd_wait_store.pl';
require $base_dir.'cmd_wait_load.pl';
require $base_dir.'cmd_lcrlr.pl';
require $base_dir.'cmd_nop.pl';
require $base_dir.'cmd_load.pl';
require $base_dir.'cmd_store.pl';
require $base_dir.'cmd_storeia.pl';
require $base_dir.'cmd_storeid.pl';
require $base_dir.'cmd_move.pl';
require $base_dir.'cmd_loadia.pl';
require $base_dir.'cmd_loadid.pl';
require $base_dir.'cmd_loop.pl';
require $base_dir.'cmd_return.pl';
require $base_dir.'cmd_jump.pl';
require $base_dir.'cmd_pulse.pl';
require $base_dir.'cmd_branch.pl';
require $base_dir.'cmd_fifo.pl';

require $base_dir.'cmd_alu.pl';
require $base_dir.'cmd_alui.pl';

require $base_dir.'cmd_pushpop.pl';
require $base_dir.'cmd_lin_search.pl';

require $base_dir.'cmd_insertr.pl';
require $base_dir.'cmd_inserti.pl';
require $base_dir.'cmd_extract.pl';
require $base_dir.'cmd_timer.pl';


# require $base_dir.'cmd_ocp_store.pl';
# require $base_dir.'cmd_ocp_storeid.pl';
# require $base_dir.'cmd_ocp_storeia.pl';
# require $base_dir.'cmd_ocp_storeiad.pl';
# require $base_dir.'cmd_ocp_load.pl';
# require $base_dir.'cmd_ocp_loadia.pl';

require $base_dir.'cmd_data.pl';

if ($SCS16_LINE == 0) {
    require $base_dir.'scs16_asm_body.pl';
}
else {
    require $base_dir.'scs16_line_body.pl';
}


# do not remove
# require $base_dir.'cmd_count.pl';
# require $base_dir.'cmd_wait_move.pl';
# require $base_dir.'cmd_crc.pl';
}

1;








