SELECT  'cookie' AS component
       ,'operator' AS name
       ,:operator AS  value;

SELECT 'redirect' as component
      ,'main.sql?reg_no=' + $reg_no + '&event='+$event as link