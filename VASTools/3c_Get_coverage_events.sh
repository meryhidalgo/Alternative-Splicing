#!/usr/bin/env bash

vast_dir="TO BE COMPLETED/vast_out"
vast_tools_full_table=INCLUSION_LEVELS_FULL-hg38-295.tab
min_samples=207  # 70% muestras

perl Get_Event_Stats.pl $vast_dir/$vast_tools_full_table \
	--N $min_samples \
	--VLOW \
	--outfile $vast_dir/coverage_events_$(basename $vast_tools_full_table)
