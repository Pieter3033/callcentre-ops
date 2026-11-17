-- The old form now opens the validated multi-entry workflow.
SELECT 'redirect' AS component,N'main.sql?reg_no='+sqlpage.url_encode(COALESCE($reg_no,N''))+N'&event='+sqlpage.url_encode(COALESCE($event,N''))+N'&seqno='+sqlpage.url_encode(COALESCE($seqno,N'')) AS link;
