----------- IA-643: Database Application Security -----------
----------------------- Project 2 ---------------------------

SET SERVEROUTPUT ON;
--- create a package with Get_balance_due function and
--- Insert_glaccount procedure.

-- package specification
CREATE OR REPLACE PACKAGE My_P2_Pkg AS
  FUNCTION Get_balance_due (Invc_Id NUMBER)
    RETURN NUMBER;
  PROCEDURE Insert_glaccount(Acc_Num_In IN NUMBER,
          Acc_Desc_In IN VARCHAR2);
END My_P2_Pkg;
/
SHOW ERRORS;

-- package body
CREATE OR REPLACE PACKAGE BODY My_P2_Pkg AS
  Balance_Due NUMBER;
--function to get the balance due
  FUNCTION Get_balance_due (Invc_Id NUMBER)
    RETURN NUMBER AS Balance_Due NUMBER;
  BEGIN
    SELECT (INVOICE_TOTAL - PAYMENT_TOTAL - CREDIT_TOTAL) INTO Balance_Due
      FROM INVOICES WHERE INVOICE_ID = Invc_Id;
    RETURN Balance_Due;
  END;

-- procedure to insert a record
  PROCEDURE Insert_glaccount(
      Acc_Num_In IN NUMBER,
      Acc_Desc_In IN VARCHAR2)
    AS
  BEGIN
    INSERT INTO GENERAL_LEDGER_ACCOUNTS (ACCOUNT_NUMBER, ACCOUNT_DESCRIPTION)
      VALUES (Acc_Num_In, Acc_Desc_In) ;
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      Raise_Application_Error(-20009, 'You have a duplicate Value');
    WHEN OTHERS THEN
      Raise_Application_Error(-20010, 'Error Occoured');
  END;

END My_P2_Pkg;
/
SHOW ERRORS;

-- Trigger for over payment warning
CREATE OR REPLACE TRIGGER Over_Payment_Trig
  BEFORE UPDATE OF PAYMENT_TOTAL
    ON INVOICES
  FOR EACH ROW
BEGIN
    IF (:OLD.INVOICE_TOTAL < (:NEW.PAYMENT_TOTAL + :NEW.CREDIT_TOTAL)) THEN
      Raise_Application_Error(-20008,'Over Payment, update cancelled');
    END IF;
END;
/
SHOW ERRORS;

COMMIT;
