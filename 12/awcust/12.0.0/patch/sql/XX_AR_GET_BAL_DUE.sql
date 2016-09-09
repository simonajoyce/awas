--------------------------------------------------------
--  File created - Thursday-September-19-2013   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XX_AR_GET_BAL_DUE
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "APPS"."XX_AR_GET_BAL_DUE" 
     (
          p_applied_payment_schedule_id IN NUMBER,
          p_as_of_date                  IN DATE,
          p_org_id                      IN NUMBER,
          p_class                       IN VARCHAR2 )
     RETURN NUMBER
IS
     p_amount_applied NUMBER;
     /*Bug 2453245 */
     p_adj_amount_applied NUMBER;
     p_actual_amount      NUMBER;
     p_amt_due_original   NUMBER;
     /* Bug 2610716 */
     p_cm_amount_applied NUMBER;
BEGIN
      SELECT
               NVL ( SUM ( NVL ( amount_applied, 0 ) + NVL ( earned_discount_taken, 0 ) + NVL ( unearned_discount_taken, 0 ) ), 0 )
             INTO
               p_amount_applied
             FROM
               ar_receivable_applications_all
            WHERE
               applied_payment_schedule_id     = p_applied_payment_schedule_id
               AND status                      = 'APP'
               AND NVL ( confirmed_flag, 'Y' ) = 'Y'
               AND ORG_ID = P_ORG_ID
               --AND apply_date                 <= p_as_of_date;
               and gl_posted_date               <= p_as_of_date;
     /* Added the  query to take care of On-Account CM applications Bug 2610716*/
     IF p_class = 'CM' THEN
           SELECT
                    NVL ( SUM ( amount_applied ), 0 )
                  INTO
                    p_cm_amount_applied
                  FROM
                    ar_receivable_applications_all
                 WHERE
                    payment_schedule_id = p_applied_payment_schedule_id
                    and org_id = p_org_id
                    --AND APPLY_DATE     <= P_AS_OF_DATE;
                    and gl_posted_date               <= p_as_of_date;
     END IF;
     /* Bug 2453245 Added the query to retrieve the Adjustment
     Amount applied to the Invoice */
      SELECT
               NVL ( SUM ( amount ), 0 )
             INTO
               p_adj_amount_applied
             FROM
               ar_adjustments_all
            WHERE
               payment_schedule_id = p_applied_payment_schedule_id
               AND status          = 'A'
               AND ORG_ID = P_ORG_ID
               --AND APPLY_DATE     <= P_AS_OF_DATE;
               and gl_posted_date               <= p_as_of_date;
      SELECT
               amount_due_original
             INTO
               p_amt_due_original
             FROM
               ar_payment_schedules_all
            WHERE
               payment_schedule_id = p_applied_payment_schedule_id
               and org_id = p_org_id;
     /*Bug 2453245 Added p_adj_amount_applied so that
     Adjustment amount is also taken into account while
     computing the Balance */
     /* bug4085823: Added nvl for p_cm_amount_applied */
     p_actual_amount := p_amt_due_original + p_adj_amount_applied - p_amount_applied + NVL ( p_cm_amount_applied, 0 ) ;
     RETURN ( p_actual_amount ) ;
EXCEPTION
     /* bug3481672 added NO_DATA_FOUND */
WHEN NO_DATA_FOUND THEN
     RETURN ( NULL ) ;
WHEN OTHERS THEN
     NULL;

END XX_AR_GET_BAL_DUE;
 

/
