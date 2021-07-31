#!/bin/sh

get_tspack()
{
	wget -nc -O $1.pk3 https://archive.org/download/the-specialists/$2.zip
}

get_tspack pak00 tsbeta_1.0
get_tspack pak01 tsbeta_1.0_to_1.5
get_tspack pak02 tsbeta_1.5_to_2.0
get_tspack pak03 tsbeta_2.0_to_2.1_rc2
get_tspack pak04 tsbeta_2.1_rc2_to_2.1
get_tspack pak05 tsbeta_2.1_to_3.0
