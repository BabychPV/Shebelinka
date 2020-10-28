CREATE VIEW [ШВПГКН].[Asset].[ReportOfTank]
(
	[ID],
	[TankNumber],
	[ElementName],
	[AttributeName],
	[Value]
)
AS
SELECT ea.ID ID, REPLACE(el.name,'Резервуар №', '')  TankNumber, el.name ElementName ,ea.name AttributeName, i.ValueStr--,i.Time
FROM (	SELECT ID,name
		FROM [ШВПГКН].[Asset].[Element]
		WHERE Name like ('Резервуар №%')) el
INNER JOIN [ШВПГКН].[Asset].[ElementAttribute] ea ON ea.ElementID = el.ID
CROSS APPLY ШВПГКН.Data.InterpolateDiscrete (ea.ID, N't') i
WHERE  ea.name in ('AI_Info01','AI_Info02','AI_Info03','AI_Info04','Material')
OPTION (FORCE ORDER,EMBED ERRORS)