-- Viewing pending status must not update counters or remove records from the queue.
SELECT 'redirect' AS component,N'main.sql?reg_no='+sqlpage.url_encode(COALESCE($reg_no,N''))+N'&event='+sqlpage.url_encode(COALESCE($event,N''))+N'&seqno='+sqlpage.url_encode(COALESCE($seqno,N'')) AS link;
