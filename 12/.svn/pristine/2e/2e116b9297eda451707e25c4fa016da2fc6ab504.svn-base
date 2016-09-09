--
--  $Header: SWIFT940.ctl 115.4 2004/12/21 05:47:12 svali ship $     
--
  
LOAD DATA
REPLACE

-- Record Type 20: Transaction Reference Number
INTO TABLE ce_stmt_int_tmp
WHEN rec_id_no = ':20' 
TRAILING NULLCOLS 
(rec_no			RECNUM,
 rec_id_no		POSITION(1:3)	CHAR
                    TERMINATED BY WHITESPACE "ltrim(:rec_id_no, ':')",
 column1 		POSITION(5:85)  CHAR)

-- Record Type 21: Related Reference (Not Used)
INTO TABLE ce_stmt_int_tmp
WHEN rec_id_no = ':21' 
TRAILING NULLCOLS 
(rec_no			RECNUM,
 rec_id_no		POSITION(1:3)	CHAR
                    TERMINATED BY WHITESPACE "ltrim(:rec_id_no, ':')",
 column1 		POSITION(5:85)  CHAR)

-- Record Type 25: Account Identification
INTO TABLE ce_stmt_int_tmp
WHEN rec_id_no = ':25' 
TRAILING NULLCOLS 
(rec_no			RECNUM,
 rec_id_no		POSITION(1:3)	CHAR
                    TERMINATED BY WHITESPACE "ltrim(:rec_id_no, ':')",
 column1 		POSITION(5:85)  CHAR)


-- Record Type 28: Statement Number
INTO TABLE ce_stmt_int_tmp
WHEN rec_id_no = ':28' 
TRAILING NULLCOLS 
(rec_no			RECNUM,
 rec_id_no		POSITION(1:3)	CHAR
                    TERMINATED BY WHITESPACE "ltrim(:rec_id_no, ':')",
 column1 		POSITION(5)   	CHAR
                        TERMINATED BY WHITESPACE "ltrim(:column1, ':')",
 column2                TERMINATED BY WHITESPACE)

-- Record Type 60F, 60M: Opening Balance
INTO TABLE ce_stmt_int_tmp
WHEN rec_id_no = ':60' 
TRAILING NULLCOLS 
(rec_no			RECNUM,
 rec_id_no		POSITION(1:3)	CHAR
			TERMINATED BY WHITESPACE "ltrim(:rec_id_no,':')",
 column1 		POSITION(4:4)   CHAR,
 column2 		POSITION(6:6)   CHAR,
 column3                POSITION(7:12)	CHAR,
 column4		POSITION(13:15) CHAR,
 column5		TERMINATED BY WHITESPACE "replace(decode(:column2, 'D', '-'||:column5, :column5), ',', '.') ")

-- Record Type 61: Statement Line
INTO TABLE ce_stmt_int_tmp
WHEN rec_id_no = ':61' 
TRAILING NULLCOLS 
(rec_no			RECNUM,
 rec_id_no		POSITION(1:3)	CHAR
                    TERMINATED BY WHITESPACE "ltrim(:rec_id_no, ':')",
 column1 		POSITION(5:10)  CHAR,
 column35		TERMINATED BY WHITESPACE)

-- Record Type 61: Supplimentary Detail (set rec_id_no to 9)
INTO TABLE ce_stmt_int_tmp
WHEN rec_id_no <> ':' 
TRAILING NULLCOLS 
(rec_no			RECNUM,
 rec_id_no		POSITION(1:1)   CHAR "decode(:rec_id_no, ':', '0', '9')",
 column1 		POSITION(1:80)  CHAR)

-- Record Type 86: Information to Account Owner
INTO TABLE ce_stmt_int_tmp
WHEN rec_id_no = ':86' 
TRAILING NULLCOLS 
(rec_no			RECNUM,
 rec_id_no		POSITION(1:3)	CHAR
                    TERMINATED BY WHITESPACE "ltrim(:rec_id_no, ':')",
 column1		POSITION(5:85)	CHAR)

-- Record Type 62F, 62M: Closing Balance
INTO TABLE ce_stmt_int_tmp
WHEN rec_id_no = ':62' 
TRAILING NULLCOLS 
(rec_no			RECNUM,
 rec_id_no		POSITION(1:3)	CHAR
                    TERMINATED BY WHITESPACE "ltrim(:rec_id_no, ':')",
 column1 		POSITION(4:4)   CHAR,
 column2 		POSITION(6:6)   CHAR,
 column3                POSITION(7:12)	CHAR,
 column4		POSITION(13:15) CHAR,
 column5		TERMINATED BY WHITESPACE "replace(decode(:column2, 'D', '-'||:column5, :column5), ',', '.') ")


-- Record Type 64: Closing Available Balance (Not Used)
INTO TABLE ce_stmt_int_tmp
WHEN rec_id_no = ':64' 
TRAILING NULLCOLS 
(rec_no			RECNUM,
 rec_id_no		POSITION(1:3)	CHAR
                    TERMINATED BY WHITESPACE "ltrim(:rec_id_no, ':')",
 column1 		POSITION(5:85)  CHAR)


-- Record Type 65: Forward Available Balance (Not Used)
INTO TABLE ce_stmt_int_tmp
WHEN rec_id_no = ':65' 
TRAILING NULLCOLS 
(rec_no			RECNUM,
 rec_id_no		POSITION(2:3)	CHAR
                    TERMINATED BY WHITESPACE "ltrim(:rec_id_no, ':')",
 column1 		POSITION(5:85)  CHAR)










