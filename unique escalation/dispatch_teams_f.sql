SELECT 'redirect' as component
    ,'dispatch_teams.sql?dup=' + CAST((SELECT TOP(1) Company_id FROM Companies WHERE Company_id = :company_el) AS NVARCHAR(max)) as link
WHERE (SELECT TOP(1) Company FROM Companies WHERE Company_id = :company_el) IN (SELECT DISTINCT Company FROM ApplicationDb1.dbo.dispatch_teams)

INSERT INTO ApplicationDb1.dbo.dispatch_teams([Company]
      ,[capital_air]
      ,[ProviderB]
      ,[provider_c])
VALUES
( (SELECT TOP(1) Company FROM Companies WHERE Company_id = :company_el)
 , CASE WHEN :ca is null then 0 else 1 end
 , CASE WHEN :ProviderB is null then 0 else 1 end
 , CASE WHEN :pandc is null then 0 else 1 end
 )

SELECT 'redirect' as component
    ,'dispatch_teams.sql?com=1' as link