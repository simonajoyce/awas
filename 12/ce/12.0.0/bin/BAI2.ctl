--
--  $Header: BAI2.ctl 115.4 2000/12/04 14:29:27 pkm ship     $       |
--

LOAD DATA
REPLACE
INTO TABLE ce_stmt_int_tmp
FIELDS TERMINATED BY "," 
TRAILING NULLCOLS 
(rec_no		RECNUM,
 rec_id_no	NULLIF rec_id_no =BLANKS ,
 column1  	NULLIF column1 =BLANKS "xx_ce_replace_usd(:rec_id_no,:column1)",
 column2  	NULLIF column2 =BLANKS,
 column3 	NULLIF column3 =BLANKS,
 column4  	NULLIF column4 =BLANKS,
 column5  	NULLIF column5 =BLANKS,
 column6  	NULLIF column6 =BLANKS,
 column7  	NULLIF column7 =BLANKS,
 column8  	NULLIF column8 =BLANKS,
 column9  	NULLIF column9 =BLANKS,
 column10 	NULLIF column10=BLANKS,
 column11 	NULLIF column11=BLANKS,
 column12 	NULLIF column12=BLANKS,
 column13 	NULLIF column13=BLANKS,
 column14 	NULLIF column14=BLANKS,
 column15 	NULLIF column15=BLANKS,
 column16 	NULLIF column16=BLANKS,
 column17 	NULLIF column17=BLANKS,
 column18 	NULLIF column18=BLANKS,
 column19 	NULLIF column19=BLANKS,
 column20 	NULLIF column20=BLANKS,
 column21 	NULLIF column21=BLANKS,
 column22 	NULLIF column22=BLANKS,
 column23 	NULLIF column23=BLANKS,
 column24 	NULLIF column24=BLANKS,
 column25 	NULLIF column25=BLANKS,
 column26 	NULLIF column26=BLANKS,
 column27 	NULLIF column27=BLANKS,
 column28 	NULLIF column28=BLANKS,
 column29 	NULLIF column29=BLANKS,
 column30 	NULLIF column30=BLANKS,
 column31 	NULLIF column31=BLANKS,
 column32 	NULLIF column32=BLANKS,
 column33 	NULLIF column33=BLANKS,
 column34 	NULLIF column34=BLANKS,
 column35 	NULLIF column35=BLANKS)















