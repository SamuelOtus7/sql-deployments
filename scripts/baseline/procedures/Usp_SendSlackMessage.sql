-- ============================================================
-- BASELINE: dbo.Usp_SendSlackMessage
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_SendSlackMessage]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Usp_SendSlackMessage]
(
	@mensagem varchar(1000)
)

as

begin

	declare @rota varchar(1250) = 'https://hooks.slack.com/services/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'
	
	Declare @Object as Int;
	Declare @ResponseText as Varchar(8000);

	Declare @Body as varchar(8000) = 
	'{
		"text": "' + @mensagem + '"
	}'
	print @Body
	
	Exec sp_OACreate 'MSXML2.ServerXMLHTTP', @Object OUT;
	EXEC  sp_OAMethod @Object, 'open', NULL, 'post',@rota, 'false'

	Exec sp_OAMethod @Object, 'setRequestHeader', null, 'Content-Type', 'application/json'
	Exec sp_OAMethod @Object, 'send', null, @Body

	Exec sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT
	Select @ResponseText

	Exec sp_OADestroy @Object
	
end


GO
