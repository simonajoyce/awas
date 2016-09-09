--
--  $Header: EDIFACT.ctl 115.0 2000/10/26 15:07:40 pkm ship     $     
--
  
LOAD DATA
REPLACE

-- Record Type 01: Header
INTO TABLE ce_stmt_int_tmp
WHEN rec_id_no = '01' 
TRAILING NULLCOLS 
(rec_no			RECNUM,
 rec_id_no		POSITION(1:2)	  CHAR,
 column1 		POSITION(3:7)     CHAR "ltrim(:column1, '0')",
 column2 		POSITION(8:11)    CHAR,
 column3 		POSITION(12:16)   CHAR "ltrim(:column3, '0')",
 column4 		POSITION(17:19)   CHAR "decode(:column4, '000', NULL, :column4)",
 column5 		POSITION(20:20)   CHAR "decode(:column5, '0', NULL, :column5)",
 column6 		POSITION(21:21)   CHAR,
 column7 		POSITION(22:32)   CHAR "ltrim(:column7, '0')",
 column8		POSITION(33:34)   CHAR,
 column9 		POSITION(35:40)   CHAR,
 column10 		POSITION(41:90)   CHAR,
 column11 		POSITION(91:104)  CHAR "ltrim(:column11, '0')",
 column12 		POSITION(105:120) CHAR)

-- Record Type 04: Transaction
INTO TABLE ce_stmt_int_tmp
WHEN rec_id_no = '04' 
TRAILING NULLCOLS 
(rec_no			RECNUM,
 rec_id_no		POSITION(1:2)	  CHAR,
 column1 		POSITION(3:7)     CHAR "ltrim(:column1, '0')",
 column2 		POSITION(8:11)    CHAR,
 column3 		POSITION(12:16)   CHAR "ltrim(:column3, '0')",
 column4 		POSITION(17:19)   CHAR "decode(:column4, '000', NULL, :column4)",
 column5 		POSITION(20:20)   CHAR "decode(:column5, '0', NULL, :column5)",
 column6 		POSITION(21:21)   CHAR,
 column7 		POSITION(22:32)   CHAR "ltrim(:column7, '0')",
 column8		POSITION(33:34)   CHAR,
 column9 		POSITION(35:40)   CHAR,
 column10 		POSITION(41:42)   CHAR,
 column11 		POSITION(43:48)   CHAR,
 column12 		POSITION(49:79)   CHAR,
 column13 		POSITION(80:81)   CHAR,
 column14 		POSITION(82:88)   CHAR "ltrim(decode(:column14, '0000000', NULL, :column14), '0')",
 column15 		POSITION(89:89)   CHAR,
 column16 		POSITION(90:90)   CHAR,
 column17 		POSITION(91:104)  CHAR "ltrim(:column17, '0')",
 column18		POSITION(105:120) CHAR)

-- Record Type 07: Trailer
INTO TABLE ce_stmt_int_tmp
WHEN rec_id_no = '07' 
TRAILING NULLCOLS 
(rec_no			RECNUM,
 rec_id_no		POSITION(1:2)	  CHAR,
 column1 		POSITION(3:7)     CHAR "ltrim(:column1, '0')",
 column2 		POSITION(8:11)    CHAR,
 column3 		POSITION(12:16)   CHAR "ltrim(:column3, '0')",
 column4 		POSITION(17:19)   CHAR "decode(:column4, '000', NULL, :column4)",
 column5 		POSITION(20:20)   CHAR "decode(:column5, '0', NULL, :column5)",
 column6 		POSITION(21:21)   CHAR,
 column7 		POSITION(22:32)   CHAR "ltrim(:column7, '0')",
 column8		POSITION(33:34)   CHAR,
 column9 		POSITION(35:40)   CHAR,
 column10 		POSITION(41:90)   CHAR,
 column11 		POSITION(91:104)  CHAR "ltrim(:column11, '0')",
 column12 		POSITION(105:120) CHAR)








