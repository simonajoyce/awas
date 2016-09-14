/* The following Update statement will update all NEW FA Mass Additions
with the Asset Category if none has been save already and the Asset Cost
Clearing account is not 159005
Developed for AWAS. 14-Sep-2016.  sjoyce - Version 1 Ltd
*/
 UPDATE fa_mass_additions x
SET asset_category_id =
       (
               SELECT cb.category_id
                 FROM fa_mass_additions ma
                   , gl_code_combinations gcc
                   , fa_category_books cb
                WHERE ma.PAYABLES_CODE_COMBINATION_ID = gcc.code_combination_id
                 AND mass_addition_id                 = x.mass_addition_id
                 AND gcc.segment2                    <> '159005'
                 AND ma.BOOK_TYPE_CODE                = cb.BOOK_TYPE_CODE
                 AND cb.ASSET_CLEARING_ACCT           = gcc.segment2
       )
  WHERE asset_category_id IS NULL
   AND mass_addition_id   IN
       (
               SELECT mass_addition_id
                 FROM fa_mass_additions ma
                   , gl_code_combinations gcc
                   , fa_category_books cb
                WHERE ma.PAYABLES_CODE_COMBINATION_ID = gcc.code_combination_id
                 AND mass_addition_id                 = x.mass_addition_id
                 AND gcc.segment2                    <> '159005'
                 AND ma.BOOK_TYPE_CODE                = cb.BOOK_TYPE_CODE
                 AND cb.ASSET_CLEARING_ACCT           = gcc.segment2
       )
   AND queue_name = 'NEW';