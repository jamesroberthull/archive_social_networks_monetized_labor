capture close

use /trainee/jrhull/diss/ch2/c2data/c2_0010B

graph matrix vh_ph_pd vh_pr_pd vh_px_pd, half 
graph export /afs/isis.unc.edu/home/j/r/jrhull/a_data/graph_nov/c2_00_vill_dv_pd_001.png, replace

graph matrix vh_ph_fr vh_pr_fr vh_px_fr, half 
graph export /afs/isis.unc.edu/home/j/r/jrhull/a_data/graph_nov/c2_00_vill_dv_fr_001.png, replace


capture close

use /trainee/jrhull/diss/ch2/c2data/c2_00_rl

graph matrix rice_rat vh_ph_pd vh_pr_pd vh_px_pd v_pro_pd, half 
graph export /afs/isis.unc.edu/home/j/r/jrhull/a_data/graph_nov/c2_00_vill_rice_rat_001.png, replace
