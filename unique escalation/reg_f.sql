/*Inserts into Reg Check, to see if reg exists*/
INSERT INTO Reg_Check(reg_no)
VALUES(:regg)

-----------------------------------------------------------------------------

/**Registration**/
SELECT  'cookie' AS component
       ,'regg' AS name
       ,:regg AS value;

SELECT 'redirect' as component
    ,'loading_1.sql?regg=' + :regg as link